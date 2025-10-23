using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using PaymentApi.Services;
using Serilog;
using Serilog.Formatting.Compact;
using OpenTelemetry.Instrumentation.Runtime;
using OpenTelemetry.Instrumentation.Process;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog for structured logging with trace context
Log.Logger = new LoggerConfiguration()
    .Enrich.FromLogContext()
    .Enrich.WithEnvironmentName()
    .Enrich.WithMachineName()
    .Enrich.WithProperty("ServiceName", "payment-api-instrumented")
    .Enrich.WithProperty("ServiceVersion", "1.0.0")
    .Enrich.WithProperty("ServiceNamespace", "ebanking.observability")
    .Enrich.WithProperty("DeploymentEnvironment", Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production")
    .Enrich.WithProperty("ContainerId", Environment.GetEnvironmentVariable("HOSTNAME") ?? Environment.MachineName)
    .Enrich.WithProperty("HostType", "container")
    .WriteTo.Console(new CompactJsonFormatter())
    .CreateLogger();

builder.Host.UseSerilog();

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSingleton<PaymentService>();

// Configure OpenTelemetry with proper resource attributes
var serviceName = "payment-api-instrumented";
var serviceVersion = "1.0.0";
var serviceInstanceId = Environment.GetEnvironmentVariable("HOSTNAME") ?? Environment.MachineName;

// Register ActivitySource
var activitySource = new System.Diagnostics.ActivitySource(serviceName);

builder.Services.AddOpenTelemetry()
    .ConfigureResource(resource => resource
        .AddService(
            serviceName: serviceName, 
            serviceVersion: serviceVersion,
            serviceInstanceId: serviceInstanceId)
        .AddAttributes(new Dictionary<string, object>
        {
            // Deployment attributes
            ["deployment.environment"] = builder.Environment.EnvironmentName.ToLowerInvariant(),
            ["deployment.environment.type"] = "docker",
            
            // Service attributes
            ["service.namespace"] = "ebanking.observability",
            ["service.instance.id"] = serviceInstanceId,
            
            // Host attributes (OpenTelemetry semantic conventions)
            ["host.name"] = Environment.MachineName,
            ["host.id"] = serviceInstanceId,
            ["host.type"] = "container",
            
            // Container attributes
            ["container.name"] = Environment.GetEnvironmentVariable("HOSTNAME") ?? "unknown",
            ["container.id"] = Environment.GetEnvironmentVariable("HOSTNAME") ?? "unknown",
            ["container.runtime"] = "docker",
            
            // Cloud/Infrastructure attributes
            ["cloud.platform"] = "docker-compose",
            ["cloud.provider"] = "on-premise",
            
            // Application metadata
            ["app.team"] = "platform-engineering",
            ["app.owner"] = "observability-team",
            ["app.tier"] = "backend",
            ["app.type"] = "instrumented-demo",
            ["app.purpose"] = "observability-testing"
        }))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation(options =>
        {
            options.RecordException = true;
            options.EnrichWithHttpRequest = (activity, httpRequest) =>
            {
                activity.SetTag("http.request.body.size", httpRequest.ContentLength);
            };
            options.EnrichWithHttpResponse = (activity, httpResponse) =>
            {
                activity.SetTag("http.response.body.size", httpResponse.ContentLength);
            };
        })
        .AddHttpClientInstrumentation()
        .AddSqlClientInstrumentation(options =>
        {
            options.SetDbStatementForText = true;
            options.RecordException = true;
        })
        .AddSource(serviceName)
        .SetSampler(new AlwaysOnSampler()) // Ensure all traces are sampled
        .AddConsoleExporter() // Debug: verify traces are being created
        .AddOtlpExporter(options =>
        {
            var endpoint = builder.Configuration["OpenTelemetry:OtlpEndpoint"] ?? "http://tempo:4317";
            options.Endpoint = new Uri(endpoint);
            options.Protocol = OpenTelemetry.Exporter.OtlpExportProtocol.Grpc;
            
            // Log the endpoint for debugging
            Console.WriteLine($"[OpenTelemetry] OTLP Exporter configured with endpoint: {endpoint}");
        }))
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddRuntimeInstrumentation()
        .AddProcessInstrumentation()
        .AddMeter("PaymentApi")
        .AddPrometheusExporter());

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors();
app.UseSerilogRequestLogging();

// Prometheus metrics endpoint
app.MapPrometheusScrapingEndpoint();

app.MapControllers();

// Health check endpoint
app.MapGet("/health", () => Results.Ok(new
{
    status = "healthy",
    service = serviceName,
    version = serviceVersion,
    timestamp = DateTime.UtcNow
}));

// Metrics endpoint (for debugging)
app.MapGet("/api/metrics", (PaymentService paymentService) =>
{
    return Results.Ok(paymentService.GetMetrics());
});

try
{
    Log.Information("Starting Payment API service");
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
