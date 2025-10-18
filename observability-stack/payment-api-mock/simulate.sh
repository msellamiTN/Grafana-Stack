#!/bin/bash

# Configuration
API_URL="http://localhost:8080/api/payments"
NUM_REQUESTS=100
MAX_DELAY=2  # seconds

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to generate a random amount
random_amount() {
    printf "%.2f" $(echo "scale=2; $RANDOM / 32767 * 1000" | bc)
}

# Function to generate a random currency
random_currency() {
    currencies=("USD" "EUR" "GBP")
    echo ${currencies[$RANDOM % ${#currencies[@]}]}
}

# Function to generate a random customer ID
random_customer() {
    echo "cust_$(shuf -i 1000-9999 -n 1)"
}

# Function to make a payment request
make_payment() {
    local amount=$1
    local currency=$2
    local customer=$3
    
    response=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "{\"amount\":$amount,\"currency\":\"$currency\",\"customerId\":\"$customer\"}")
    
    if [ "$response" -eq 200 ]; then
        echo -e "${GREEN}SUCCESS${NC}: $amount $currency - Customer: $customer"
    else
        echo -e "${RED}ERROR${NC} ($response): $amount $currency - Customer: $customer"
    fi
}

# Main simulation
echo "Starting payment simulation..."
echo "API URL: $API_URL"
echo "Number of requests: $NUM_REQUESTS"
echo "Max delay between requests: ${MAX_DELAY}s"
echo "----------------------------------------"

for ((i=1; i<=NUM_REQUESTS; i++)); do
    amount=$(random_amount)
    currency=$(random_currency)
    customer=$(random_customer)
    
    echo -n "[$i/$NUM_REQUESTS] "
    make_payment "$amount" "$currency" "$customer"
    
    # Random delay between requests (0 to MAX_DELAY seconds)
    if [ $i -lt $NUM_REQUESTS ]; then
        delay=$(echo "scale=2; $RANDOM * $MAX_DELAY / 32767" | bc)
        sleep $delay
    fi
done

echo "----------------------------------------"
echo "Simulation completed!"
