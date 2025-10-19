from fastapi import FastAPI, HTTPException, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime
import random
import time
import os
from dotenv import load_dotenv
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
from prometheus_fastapi_instrumentator import Instrumentator
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
    org=INFLUX_CONFIG["org"]
)
write_api = influx_client.write_api(write_options=SYNCHRONOUS)

# Models
class PaymentRequest(BaseModel):
    amount: float
    currency: str = "USD"
    customer_id: str = "anonymous"
    description: str = None

class PaymentResponse(BaseModel):
    payment_id: str
    status: str
    amount: float
    currency: str
    timestamp: str
    processing_time_ms: float

# Metrics and monitoring
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.requests import Request
from starlette.responses import Response

# Prometheus metrics
REQUEST_COUNT = Counter(
    'payment_requests_total',
    'Total number of payment requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'payment_request_duration_seconds',
    'Time spent processing payment requests',
    ['method', 'endpoint']
)

# Middleware for metrics
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

# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}

# Metrics endpoint for Prometheus
@app.get("/metrics")
async def metrics():
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )

# Process payment
@app.post("/api/payments", response_model=PaymentResponse)
async def process_payment(payment: PaymentRequest):
    start_time = time.time()
    
    # Simulate processing time (50ms to 500ms)
    processing_time = random.uniform(0.05, 0.5)
    time.sleep(processing_time)
    
    # Simulate 2% failure rate
    is_success = random.random() > 0.02
    
    # Create payment record
    payment_id = f"pay_{int(time.time() * 1000)}_{random.randint(1000, 9999)}"
    timestamp = datetime.utcnow().isoformat()
    
    # Write to InfluxDB
    try:
        point = Point("payment")\
            .tag("status", "success" if is_success else "failed")\
            .tag("currency", payment.currency)\
            .tag("customer_id", payment.customer_id)\
            .field("amount", float(payment.amount))\
            .field("processing_time", processing_time)\
            .time(datetime.utcnow())
            
        write_api.write(
            bucket=INFLUX_CONFIG["bucket"],
            org=INFLUX_CONFIG["org"],
            record=point
        )
    except Exception as e:
        logger.error(f"Failed to write to InfluxDB: {str(e)}")
    
    # Prepare response
    if is_success:
        return {
            "payment_id": payment_id,
            "status": "completed",
            "amount": payment.amount,
            "currency": payment.currency,
            "timestamp": timestamp,
            "processing_time_ms": round(processing_time * 1000, 2)
        }
    else:
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail="Payment processing failed"
        )

# Get payment statistics
@app.get("/api/payments/stats")
async def get_payment_stats():
    try:
        # This is a simplified example - you'd typically query InfluxDB here
        return {
            "total_payments": 0,  # Replace with actual query
            "success_rate": 1.0,   # Replace with actual calculation
            "avg_processing_time": 0.0  # Replace with actual calculation
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

# Initialize Prometheus instrumentation
Instrumentator().instrument(app).expose(app)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)
