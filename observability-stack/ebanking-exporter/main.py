#!/usr/bin/env python3
"""
eBanking Metrics Exporter
Prometheus metrics exporter for eBanking application
"""

import time
import random
from prometheus_client import start_http_server, Counter, Gauge, Histogram
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Define Prometheus metrics
transactions_processed = Counter(
    'ebanking_transactions_processed_total',
    'Total number of processed transactions',
    ['transaction_type', 'status']
)

active_sessions = Gauge(
    'ebanking_active_sessions',
    'Current number of active sessions'
)

account_balance = Gauge(
    'ebanking_account_balance_total',
    'Total account balance across all accounts',
    ['currency']
)

request_duration = Histogram(
    'ebanking_request_duration_seconds',
    'Time taken to process requests',
    ['endpoint'],
    buckets=[0.1, 0.2, 0.5, 1.0, 2.0, 5.0]
)

login_attempts = Counter(
    'ebanking_login_attempts_total',
    'Total number of login attempts',
    ['status']
)

transfer_amount = Histogram(
    'ebanking_transfer_amount',
    'Transfer amounts in EUR',
    buckets=[10, 50, 100, 500, 1000, 5000, 10000]
)

api_errors = Counter(
    'ebanking_api_errors_total',
    'Total number of API errors',
    ['error_type']
)

database_connections = Gauge(
    'ebanking_database_connections',
    'Current number of database connections'
)


def simulate_metrics():
    """Simulate realistic eBanking metrics"""
    logger.info("Starting metrics simulation...")
    
    transaction_types = ['transfer', 'payment', 'withdrawal', 'deposit']
    statuses = ['success', 'failed', 'pending']
    currencies = ['EUR', 'USD', 'GBP']
    endpoints = ['/api/transfer', '/api/balance', '/api/transactions', '/api/login']
    error_types = ['timeout', 'validation', 'authentication', 'network']
    
    while True:
        try:
            # Simulate transaction processing
            trans_type = random.choice(transaction_types)
            status = random.choices(statuses, weights=[85, 10, 5])[0]  # 85% success
            transactions_processed.labels(
                transaction_type=trans_type,
                status=status
            ).inc()
            
            # Simulate active sessions (50-200 users)
            active_sessions.set(random.randint(50, 200))
            
            # Simulate account balances
            for currency in currencies:
                balance = random.uniform(100000, 5000000)
                account_balance.labels(currency=currency).set(balance)
            
            # Simulate request durations
            endpoint = random.choice(endpoints)
            duration = random.uniform(0.05, 2.0)
            request_duration.labels(endpoint=endpoint).observe(duration)
            
            # Simulate login attempts
            login_status = random.choices(['success', 'failed'], weights=[95, 5])[0]
            login_attempts.labels(status=login_status).inc()
            
            # Simulate transfer amounts
            if trans_type == 'transfer':
                amount = random.uniform(10, 10000)
                transfer_amount.observe(amount)
            
            # Simulate occasional errors (5% chance)
            if random.random() < 0.05:
                error_type = random.choice(error_types)
                api_errors.labels(error_type=error_type).inc()
            
            # Simulate database connections (10-50)
            database_connections.set(random.randint(10, 50))
            
            # Wait before next iteration
            time.sleep(random.uniform(0.5, 2.0))
            
        except Exception as e:
            logger.error(f"Error in metrics simulation: {e}")
            time.sleep(1)


if __name__ == '__main__':
    # Start Prometheus metrics server on port 9200
    port = 9200
    logger.info(f"Starting eBanking Metrics Exporter on port {port}")
    start_http_server(port)
    logger.info(f"Metrics available at http://0.0.0.0:{port}/metrics")
    
    # Start metrics simulation
    simulate_metrics()
