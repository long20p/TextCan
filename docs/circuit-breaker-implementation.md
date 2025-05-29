# Polly Circuit Breaker Implementation for TextCan API

## Overview

Added **Polly circuit breaker pattern** to the TextCan API to provide resilience against the Key Generation Service being temporarily unavailable.

## What Was Added

### 1. Polly NuGet Packages
```xml
<PackageReference Include="Polly" Version="8.4.1" />
<PackageReference Include="Polly.Extensions.Http" Version="3.0.0" />
```

### 2. Circuit Breaker Configuration
**File**: `Configs/CircuitBreakerConfig.cs`
- Configurable circuit breaker settings
- Default: 3 failures before opening circuit
- Default: 1-minute break duration
- Default: 30-second timeout for HTTP requests

### 3. Enhanced UniqueKeyService
**File**: `Services/UniqueKeyService.cs`
- Integrated Polly circuit breaker pattern
- Handles HTTP failures gracefully
- Provides detailed logging for circuit breaker state changes
- Catches `BrokenCircuitException` when circuit is open

### 4. Fallback Mechanism in ContentService
**File**: `Services/ContentService.cs`
- Added fallback key generation using GUID
- Returns 8-character fallback keys when key service is unavailable
- Logs when fallback mechanism is triggered
- No longer throws exceptions when key service fails

### 5. Configuration Settings
**Files**: `appsettings.json`, `appsettings.Development.json`
```json
{
  "CircuitBreaker": {
    "HandledEventsAllowedBeforeBreaking": 3,
    "DurationOfBreak": "00:01:00",
    "Timeout": "00:00:30"
  }
}
```

## Circuit Breaker Behavior

### States
1. **Closed**: Normal operation, requests flow through
2. **Open**: Circuit is open, requests fail fast, fallback used
3. **Half-Open**: Testing if service is back online

### Triggers
- HTTP request exceptions (`HttpRequestException`)
- Task cancellations (`TaskCanceledException`)
- Non-success HTTP status codes

### Fallback Strategy
When the key service is unavailable:
1. Circuit breaker opens after 3 consecutive failures
2. ContentService automatically switches to GUID-based key generation
3. Application continues to function normally
4. Users can still create and share content

### Logging
- Circuit breaker state changes are logged with details
- Fallback key generation is logged as warnings
- HTTP errors are logged with context

## Benefits

1. **Improved Reliability**: Application continues working even when key service fails
2. **Fast Failure**: No hanging requests when service is down
3. **Automatic Recovery**: Circuit breaker automatically tests for service recovery
4. **Graceful Degradation**: Fallback key generation maintains functionality
5. **Observability**: Comprehensive logging for monitoring and debugging

## Configuration

### Production Settings (appsettings.json)
- 3 failures before opening circuit
- 1-minute break duration
- 30-second HTTP timeout

### Development Settings (appsettings.Development.json)
- 2 failures before opening circuit (faster testing)
- 30-second break duration
- 15-second HTTP timeout

## Usage

The circuit breaker is automatically activated when:
1. Key service returns HTTP errors
2. Key service times out
3. Network connectivity issues occur

No code changes are required in controllers or other services - the resilience is built into the infrastructure layer.
