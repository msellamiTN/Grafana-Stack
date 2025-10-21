FROM python:3.11-slim

WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY main.py .

# Expose metrics port
EXPOSE 9200

# Run the exporter
CMD ["python", "main.py"]
