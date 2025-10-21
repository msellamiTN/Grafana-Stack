const express = require('express');
const promClient = require('prom-client');
const cors = require('cors');
const morgan = require('morgan');
const winston = require('winston');
const { InfluxDB, Point } = require('@influxdata/influxdb-client');

// Initialize Express app
const app = express();
const port = process.env.PORT || 8080;
const simulationRate = parseInt(process.env.SIMULATION_RATE) || 5; // Transactions per second

// InfluxDB Configuration
const influxConfig = {
  url: process.env.INFLUXDB_URL || 'http://influxdb:8086',
  token: process.env.INFLUXDB_TOKEN || 'training-token-change-me',
  org: process.env.INFLUXDB_ORG || 'data2ai',
  bucket: process.env.INFLUXDB_BUCKET || 'training',
};

// Initialize InfluxDB client
const influxDB = new InfluxDB({ url: influxConfig.url, token: influxConfig.token });
const writeApi = influxDB.getWriteApi(influxConfig.org, influxConfig.bucket);

// Handle InfluxDB write errors
writeApi.on('error', (error) => {
  console.error('InfluxDB write error:', error);
  logger.error('InfluxDB write error', { error: error.message });
});

// Graceful shutdown for InfluxDB
process.on('SIGTERM', () => {
  writeApi.close()
    .then(() => {
      logger.info('InfluxDB write API closed');
      process.exit(0);
    })
    .catch((err) => {
      logger.error('Error closing InfluxDB', { error: err.message });
      process.exit(1);
    });
});

// Configure logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
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
  labelNames: ['method', 'status', 'type', 'currency']
});

const paymentAmount = new promClient.Histogram({
  name: 'payment_amount',
  help: 'Amount processed per payment',
  labelNames: ['currency', 'status'],
  buckets: [10, 50, 100, 500, 1000, 5000, 10000, 50000]
});

const paymentDuration = new promClient.Histogram({
  name: 'payment_duration_seconds',
  help: 'Duration of payment processing in seconds',
  labelNames: ['status'],
  buckets: [0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 1, 2, 3, 5]
});

const activePayments = new promClient.Gauge({
  name: 'active_payments',
  help: 'Number of payments currently being processed'
});

const dailyRevenue = new promClient.Gauge({
  name: 'payment_daily_revenue',
  help: 'Daily revenue from processed payments',
  labelNames: ['currency']
});

const failureRate = new promClient.Gauge({
  name: 'payment_failure_rate',
  help: 'Current payment failure rate (percentage)'
});

// Revenue tracking
const revenueTracking = {
  USD: 0,
  EUR: 0,
  GBP: 0
};

// Write payment data to InfluxDB
const writePaymentToInflux = async (payment, result) => {
  try {
    const point = new Point('payment')
      .tag('status', result.success ? 'success' : 'failed')
      .tag('currency', payment.currency || 'USD')
      .tag('customer_id', payment.customerId || 'anonymous')
      .tag('payment_type', payment.type || 'standard')
      .floatField('amount', parseFloat(payment.amount))
      .floatField('processing_time', result.processingTime)
      .timestamp(new Date(result.timestamp));

    writeApi.writePoint(point);
    await writeApi.flush();
  } catch (error) {
    logger.error('Failed to write to InfluxDB', { error: error.message });
  }
};

// Simulate payment processing
const processPayment = async (payment) => {
  const start = Date.now();
  activePayments.inc();
  
  // Simulate processing time (50ms to 800ms)
  const processingTime = Math.random() * 750 + 50;
  
  // Simulate 3% failure rate (more realistic)
  const isSuccess = Math.random() > 0.03;
  
  return new Promise(resolve => {
    setTimeout(async () => {
      const duration = (Date.now() - start) / 1000;
      activePayments.dec();
      
      const result = {
        success: isSuccess,
        paymentId: `pay_${Math.random().toString(36).substr(2, 12)}`,
        amount: payment.amount,
        currency: payment.currency || 'USD',
        timestamp: new Date().toISOString(),
        processingTime: duration,
        customerId: payment.customerId
      };
      
      // Record metrics
      const statusLabel = isSuccess ? 'success' : 'failed';
      paymentDuration.observe({ status: statusLabel }, duration);
      paymentAmount.observe({ currency: result.currency, status: statusLabel }, parseFloat(payment.amount));
      
      // Update revenue tracking
      if (isSuccess) {
        revenueTracking[result.currency] = (revenueTracking[result.currency] || 0) + parseFloat(payment.amount);
        dailyRevenue.set({ currency: result.currency }, revenueTracking[result.currency]);
      }
      
      // Store in InfluxDB
      await writePaymentToInflux(payment, result);
      
      resolve(result);
    }, processingTime);
  });
};

// Routes
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'UP',
    service: 'payment-api',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
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

// Get payment statistics
app.get('/api/payments/stats', async (req, res) => {
  try {
    const stats = {
      revenue: revenueTracking,
      timestamp: new Date().toISOString()
    };
    res.status(200).json(stats);
  } catch (error) {
    logger.error('Failed to get payment stats', { error: error.message });
    res.status(500).json({ error: 'Failed to retrieve payment statistics' });
  }
});

// Process payment
app.post('/api/payments', async (req, res) => {
  try {
    const { amount, currency, customerId, type } = req.body;
    
    if (!amount || isNaN(amount) || amount <= 0) {
      paymentCounter.inc({ method: 'POST', status: '400', type: 'invalid_request', currency: 'N/A' });
      return res.status(400).json({ error: 'Invalid amount' });
    }
    
    const payment = { 
      amount, 
      currency: currency || 'USD', 
      customerId: customerId || `cust_${Math.floor(Math.random() * 10000)}`,
      type: type || 'standard'
    };
    
    const result = await processPayment(payment);
    
    if (result.success) {
      paymentCounter.inc({ method: 'POST', status: '200', type: 'success', currency: result.currency });
      res.status(200).json(result);
    } else {
      paymentCounter.inc({ method: 'POST', status: '500', type: 'failed', currency: result.currency });
      res.status(500).json({ error: 'Payment processing failed', ...result });
    }
  } catch (error) {
    paymentCounter.inc({ method: 'POST', status: '500', type: 'error', currency: 'N/A' });
    logger.error('Payment processing error', { error: error.message });
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get payment by ID (mock)
app.get('/api/payments/:id', (req, res) => {
  const { id } = req.params;
  res.status(200).json({
    paymentId: id,
    status: 'completed',
    amount: (Math.random() * 1000).toFixed(2),
    currency: 'USD',
    timestamp: new Date().toISOString()
  });
});

// Start server
const server = app.listen(port, () => {
  logger.info('='.repeat(60));
  logger.info('Payment API Mock - Training Version');
  logger.info('Data2AI Academy');
  logger.info('='.repeat(60));
  logger.info(`Server running on port ${port}`);
  logger.info(`Metrics available at http://localhost:${port}/metrics`);
  logger.info(`Health check at http://localhost:${port}/health`);
  logger.info(`Simulation rate: ${simulationRate} transactions/second`);
  logger.info('='.repeat(60));
  
  // Simulate traffic if enabled
  if (process.env.NODE_ENV !== 'test' && process.env.ENABLE_SIMULATION !== 'false') {
    logger.info('Starting payment simulation...');
    
    setInterval(() => {
      // Random amount between 10 and 5000
      const amount = (Math.random() * 4990 + 10).toFixed(2);
      const currencies = ['USD', 'EUR', 'GBP'];
      const currency = currencies[Math.floor(Math.random() * currencies.length)];
      const types = ['standard', 'express', 'recurring'];
      const type = types[Math.floor(Math.random() * types.length)];
      
      processPayment({ 
        amount, 
        currency, 
        customerId: `cust_${Math.floor(Math.random() * 1000)}`,
        type
      })
        .then(result => {
          if (!result.success) {
            logger.warn('Simulated payment failed', { paymentId: result.paymentId, amount, currency });
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
    writeApi.close().then(() => {
      logger.info('InfluxDB connection closed');
      process.exit(0);
    });
  });
});

module.exports = { app, server };
