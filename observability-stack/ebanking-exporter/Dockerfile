# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder

WORKDIR /app
COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o out --self-contained true --runtime linux-x64 /p:PublishSingleFile=true /p:PublishTrimmed=true

# Runtime stage
FROM mcr.microsoft.com/dotnet/runtime:8.0-alpine

RUN apk add --no-cache icu-libs
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

WORKDIR /app
COPY --from=builder /app/out .

EXPOSE 9200
ENTRYPOINT ["./ebanking-exporter"]
