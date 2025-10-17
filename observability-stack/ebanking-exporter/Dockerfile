# Build stage
FROM golang:1.20-alpine AS builder

WORKDIR /app
COPY go.mod ./
# Generate go.sum if it doesn't exist
RUN go mod tidy
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o ebanking-exporter

# Final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/ebanking-exporter .
EXPOSE 9200
CMD ["./ebanking-exporter"]
