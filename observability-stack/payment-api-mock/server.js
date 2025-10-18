const express = require('express');
const promBundle = require('express-prom-bundle');
const promClient = require('prom-client');
const cors = require('cors');
const morgan = require('morgan');
const winston = require('winston');

// Initialize Express app
const app = express();
const port = process.env.PORT || 8080;
const simulationRate = parseInt(process.env.SIMULATION_RATE) || 5; // Transactions per second

// Configure logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'payment-api.log' })
  ]
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));

// Prometheus metrics setup
const collectDefaultMetrics = promClient.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

// Custom metrics
const paymentCounter = new promClient.Counter({
  name: 'payment_requests_total',
  help: 'Total number of payment requests',
  labelNames: ['method', 'status', 'type']
});

const paymentAmount = new promClient.Histogram({
  name: 'payment_amount',
  help: 'Amount processed per payment',
  labelNames: ['currency'],
  buckets: [10, 50, 100, 500, 1000, 5000, 10000]
});

const paymentDuration = new promClient.Histogram({
  name: 'payment_duration_seconds',
  help: 'Duration of payment processing in seconds',
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 10]
});

const activePayments = new promClient.Gauge({
  name: 'active_payments',
  help: 'Number of payments currently being processed'
});

// Simulate payment processing
const processPayment = (payment) => {
  const start = Date.now();
  activePayments.inc();
  
  // Simulate processing time (50ms to 500ms)
  const processingTime = Math.random() * 450 + 50;
  
  // Simulate 2% failure rate
  const isSuccess = Math.random() > 0.02;
  
  return new Promise(resolve => {
    setTimeout(() => {
      const duration = (Date.now() - start) / 1000;
      activePayments.dec();
      
      const result = {
        success: isSuccess,
        paymentId: `tx_${Math.random().toString(36).substr(2, 9)}`,
        amount: payment.amount,
        currency: payment.currency || 'USD',
        timestamp: new Date().toISOString(),
        processingTime: duration
      };
      
      // Record metrics
      paymentDuration.observe(duration);
      paymentAmount.observe({ currency: result.currency }, parseFloat(payment.amount));
      
      resolve(result);
    }, processingTime);
  });
};

// Routes
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', promClient.register.contentType);
    const metrics = await promClient.register.metrics();
    res.end(metrics);
  } catch (err) {
    logger.error('Error generating metrics', { error: err.message });
    res.status(500).end();
  }
});

app.post('/api/payments', async (req, res) => {
  try {
    const { amount, currency, customerId } = req.body;
    
    if (!amount || isNaN(amount)) {
      paymentCounter.inc({ method: 'POST', status: '400', type: 'invalid_request' });
      return res.status(400).json({ error: 'Invalid amount' });
    }
    
    const payment = { amount, currency, customerId };
    const result = await processPayment(payment);
    
    if (result.success) {
      paymentCounter.inc({ method: 'POST', status: '200', type: 'success' });
      res.status(200).json(result);
    } else {
      paymentCounter.inc({ method: 'POST', status: '500', type: 'failed' });
      res.status(500).json({ error: 'Payment processing failed', ...result });
    }
  } catch (error) {
    paymentCounter.inc({ method: 'POST', status: '500', type: 'error' });
    logger.error('Payment processing error', { error: error.message });
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start server
const server = app.listen(port, () => {
  logger.info(`Payment API Mock running on port ${port}`);
  
  // Simulate traffic if enabled
  if (process.env.NODE_ENV !== 'test') {
    setInterval(() => {
      const amount = (Math.random() * 1000).toFixed(2);
      const currencies = ['USD', 'EUR', 'GBP'];
      const currency = currencies[Math.floor(Math.random() * currencies.length)];
      
      processPayment({ amount, currency, customerId: `cust_${Math.floor(Math.random() * 1000)}` })
        .then(result => {
          if (!result.success) {
            logger.warn('Simulated payment failed', { paymentId: result.paymentId });
          }
        })
        .catch(err => logger.error('Error in simulated payment', { error: err.message }));
    }, 1000 / simulationRate);
  }
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Shutting down gracefully');
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});

module.exports = { app, server };
