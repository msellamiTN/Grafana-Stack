using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Prometheus;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace EBankingMetricsExporter
{
    public class Program
    {
        // Define Prometheus metrics
        private static readonly Counter TransactionsProcessed = Metrics.CreateCounter(
            "ebanking_transactions_processed_total",
            "Total number of processed transactions");

        private static readonly Gauge ActiveSessions = Metrics.CreateGauge(
            "ebanking_active_sessions",
            "Current number of active sessions");

        private static readonly Histogram RequestDurations = Metrics.CreateHistogram(
            "ebanking_request_duration_seconds",
            "Time taken to process requests",
            new HistogramConfiguration
            {
                Buckets = new[] { 0.1, 0.2, 0.5, 1.0, 2.0, 5.0 }
            });

        public static async Task Main(string[] args)
        {
            var host = Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                    webBuilder.UseUrls("http://0.0.0.0:9200");
                })
                .ConfigureLogging(logging =>
                {
                    logging.ClearProviders();
                    logging.AddConsole();
                })
                .Build();

            // Start metrics simulation in background
            _ = Task.Run(() => SimulateMetrics());

            await host.RunAsync();
        }

        private static void SimulateMetrics()
        {
            var random = new Random();

            while (true)
            {
                try
                {
                    // Increment transactions counter
                    TransactionsProcessed.Inc();

                    // Update active sessions (between 50 and 200)
                    ActiveSessions.Set(50 + random.Next(150));

                    // Simulate request duration
                    using (RequestDurations.NewTimer())
                    {
                        // Simulate processing time (100-500ms)
                        Thread.Sleep(100 + random.Next(400));
                    }

                    // Wait 1 second before next iteration
                    Thread.Sleep(1000);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error in metrics simulation: {ex.Message}");
                    Thread.Sleep(1000);
                }
            }
        }
    }

    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            // Add Prometheus metrics service
            services.AddMetricServer(options =>
            {
                options.Port = 9200;
            });
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            // Enable Prometheus metrics endpoint
            app.UseMetricServer();

            // Health check endpoint
            app.Map("/health", healthApp =>
            {
                healthApp.Run(async context =>
                {
                    context.Response.StatusCode = 200;
                    await context.Response.WriteAsync("OK");
                });
            });

            // Root endpoint with info
            app.Map("/", appBuilder =>
            {
                appBuilder.Run(async context =>
                {
                    context.Response.StatusCode = 200;
                    await context.Response.WriteAsync("eBanking Metrics Exporter\n\nEndpoints:\n- /metrics (Prometheus metrics)\n- /health (Health check)");
                });
            });
        }
    }
}
