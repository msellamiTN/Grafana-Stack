from fastapi import FastAPI, HTTPException, Request, status
from fastapi.responses import JSONResponse, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime
import random
import time
import os
from dotenv import load_dotenv
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import logging

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# InfluxDB configuration
INFLUX_CONFIG = {
    "url": os.getenv("INFLUXDB_URL", "http://influxdb:8086"),
    "token": os.getenv("INFLUXDB_TOKEN", "my-super-secret-auth-token"),
    "org": os.getenv("INFLUXDB_ORG", "myorg"),
    "bucket": os.getenv("INFLUXDB_BUCKET", "payments")
}

# Initialize FastAPI app
app = FastAPI(title="Payment API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize InfluxDB client
influx_client = InfluxDBClient(
    url=INFLUX_CONFIG["url"],
    token=INFLUX_CONFIG["token"],
    org=INFLUX_CONFIG["org"],
    verify_ssl=False,
    ssl=False
)
write_api = influx_client.write_api(write_options=SYNCHRONOUS)

# === PROMETHEUS METRICS ===
# These match the dashboard requirements exactly

PAYMENT_AMOUNT = Counter(
    'payment_amount_sum',
    'Total payment amount in base currency (e.g., EUR)',
    ['status', 'currency', 'payment_method', 'region', 'card_brand']
)

PAYMENT_COUNT = Counter(
    'payment_count_total',
    'Total number of payment transactions',
    ['status', 'currency', 'payment_method', 'region', 'card_brand']
)

PAYMENT_PROCESSING_DURATION = Histogram(
    'payment_processing_duration_seconds',
    'Processing time of payment transactions',
    ['status', 'payment_method', 'region', 'card_brand'],
    buckets=[0.05, 0.1, 0.2, 0.3, 0.5, 0.8, 1.0, 2.0, 5.0]  # seconds
)

# Optional: generic HTTP metrics (already partially covered)
from prometheus_client import Counter as GenericCounter, Histogram as GenericHistogram

REQUEST_COUNT = GenericCounter(
    'payment_requests_total',
    'Total HTTP requests to payment endpoints',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = GenericHistogram(
    'payment_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

# === Helper functions ===

def generate_realistic_amount() -> float:
    rand = random.random()
    if rand < 0.80:
        return round(random.gauss(75, 45), 2)
    elif rand < 0.95:
        return round(random.gauss(500, 250), 2)
    else:
        return round(random.gauss(2000, 1000), 2)

def generate_processing_time(status: str) -> float:
    if status == "success":
        return max(0.05, round(random.gauss(0.24, 0.10), 3))
    else:
        return max(0.1, round(random.gauss(0.80, 0.35), 3))

# === Models ===

class PaymentRequest(BaseModel):
    amount: float = 0.0
    currency: str = "EUR"
    customer_id: str = "anonymous"
    description: str = None

class PaymentResponse(BaseModel):
    payment_id: str
    status: str
    amount: float
    currency: str
    timestamp: str
    processing_time_ms: float

# === Middleware for generic HTTP metrics ===

@app.middleware("http")
async def monitor_requests(request: Request, call_next):
    start_time = time.time()
    method = request.method
    endpoint = request.url.path

    try:
        response = await call_next(request)
        status_code = response.status_code
        REQUEST_COUNT.labels(method, endpoint, status_code).inc()
        REQUEST_LATENCY.labels(method, endpoint).observe(time.time() - start_time)
        return response
    except Exception as e:
        status_code = 500
        REQUEST_COUNT.labels(method, endpoint, status_code).inc()
        raise e

# === Endpoints ===

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}

@app.get("/metrics")
async def metrics():
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )

@app.post("/api/payments", response_model=PaymentResponse)
async def process_payment(payment: PaymentRequest):
    start_time = time.time()

    # Determine status
    status_rand = random.random()
    if status_rand < 0.97:
        status = "success"
    elif status_rand < 0.99:
        status = "failed"
    else:
        status = "pending"

    is_success = status == "success"
    amount = payment.amount if payment.amount > 0 else generate_realistic_amount()
    processing_time = generate_processing_time(status)
    time.sleep(processing_time)

    # Generate realistic tags
    payment_method = random.choice(["card", "bank_transfer", "wallet", "crypto"])
    region = random.choice(["EU", "US", "ASIA", "LATAM"])
    card_brand = random.choice(["VISA", "MASTERCARD", "AMEX", "DISCOVER"])
    merchant_id = f"merch_{random.randint(1, 500):04d}"

    # === INFLUXDB WRITE ===
    try:
        point = Point("payment")
        point.tag("status", status)
        point.tag("currency", payment.currency)
        point.tag("customer_id", payment.customer_id)
        point.tag("merchant_id", merchant_id)
        point.tag("payment_method", payment_method)
        point.tag("region", region)
        point.tag("card_brand", card_brand)
        point.tag("risk_level", random.choices(
            ["low", "medium", "high", "critical"],
            weights=[0.80, 0.15, 0.04, 0.01]
        )[0])

        point.field("amount", float(amount))
        point.field("processing_time", processing_time)
        point.field("network_latency", round(random.uniform(5, 50), 1))
        point.field("gateway_latency", round(random.uniform(10, 100), 1))
        point.field("error_code", 0 if is_success else random.randint(5001, 5010))
        point.field("retry_count", 0 if is_success else random.randint(1, 3))
        point.field("fraud_score", round(random.uniform(0, 0.05), 3) if is_success 
                    else round(random.uniform(0.70, 1.0), 3))
        point.field("response_time", processing_time * 1000)
        point.field("fee", round(amount * 0.029 + 0.30, 2))
        point.field("success", 1 if is_success else 0)
        point.time(datetime.utcnow())

        write_api.write(
            bucket=INFLUX_CONFIG["bucket"],
            org=INFLUX_CONFIG["org"],
            record=point
        )
        logger.info(f"Payment written to InfluxDB: {status}")
    except Exception as e:
        logger.error(f"Failed to write to InfluxDB: {str(e)}")

    # === PROMETHEUS METRICS UPDATE ===
    labels = {
        "status": status,
        "currency": payment.currency,
        "payment_method": payment_method,
        "region": region,
        "card_brand": card_brand
    }

    # Count every transaction
    PAYMENT_COUNT.labels(**labels).inc()

    # Record amount only for success/failed (not pending)
    if status in ("success", "failed"):
        PAYMENT_AMOUNT.labels(**labels).inc(amount)

    # Record processing time
    PAYMENT_PROCESSING_DURATION.labels(**labels).observe(processing_time)

    # Return response
    if is_success:
        return PaymentResponse(
            payment_id=f"pay_{int(time.time() * 1000)}_{random.randint(1000, 9999)}",
            status="completed",
            amount=amount,
            currency=payment.currency,
            timestamp=datetime.utcnow().isoformat(),
            processing_time_ms=round(processing_time * 1000, 2)
        )
    else:
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail="Payment processing failed"
        )

@app.get("/api/payments/stats")
async def get_payment_stats():
    return {
        "message": "Use /metrics for Prometheus or query InfluxDB directly"
    }

# Optional: expose built-in Prometheus instrumentation (optional)
from prometheus_fastapi_instrumentator import Instrumentator
instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app, include_in_schema=False, endpoint="/metrics-auto")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)