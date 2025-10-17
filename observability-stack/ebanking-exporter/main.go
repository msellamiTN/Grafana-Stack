package main

import (
    "log"
    "math/rand"
    "net/http"
    "time"

    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    // Create a metric to track e-banking transactions
    transactionsProcessed = prometheus.NewCounter(
        prometheus.CounterOpts{
            Name: "ebanking_transactions_processed_total",
            Help: "Total number of processed transactions",
        },
    )

    // Create a gauge for active sessions
    activeSessions = prometheus.NewGauge(
        prometheus.GaugeOpts{
            Name: "ebanking_active_sessions",
            Help: "Current number of active sessions",
        },
    )

    // Create a histogram for request durations
    requestDurations = prometheus.NewHistogram(
        prometheus.HistogramOpts{
            Name:    "ebanking_request_duration_seconds",
            Help:    "Time taken to process requests",
            Buckets: []float64{0.1, 0.2, 0.5, 1, 2, 5},
        },
    )
)

func init() {
    // Register metrics with Prometheus
    prometheus.MustRegister(transactionsProcessed)
    prometheus.MustRegister(activeSessions)
    prometheus.MustRegister(requestDurations)

    // Simulate some metrics
    go func() {
        for {
            // Increment transactions
            transactionsProcessed.Inc()

            // Update active sessions (between 50 and 200)
            activeSessions.Set(float64(50 + (rand.Intn(150))))

            // Simulate some request durations
            timer := prometheus.NewTimer(requestDurations)
            time.Sleep(time.Duration(100+rand.Intn(400)) * time.Millisecond)
            timer.ObserveDuration()

            time.Sleep(1 * time.Second)
        }
    }()
}

func main() {
    // Expose metrics endpoint
    http.Handle("/metrics", promhttp.Handler())

    // Health check endpoint
    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("OK"))
    })

    // Start the server
    log.Println("Starting eBanking Exporter on :9200")
    log.Fatal(http.ListenAndServe(":9200", nil))
}
