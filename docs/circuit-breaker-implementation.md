# Polly Resilience Implementation for TextCan API

## Overview

Added **Polly resilience patterns** to the TextCan API to provide robust handling of the Key Generation Service being temporarily unavailable. This includes both **retry with exponential backoff** and **circuit breaker patterns**.

## What Was Added

### 1. Polly NuGet Packages
```xml
<PackageReference Include="Polly" Version="8.4.1" />
<PackageReference Include="Polly.Extensions.Http" Version="3.0.0" />
```

### 2. Resilience Configuration
**File**: `Configs/ResilienceConfig.cs`
- Configurable circuit breaker settings
- Default: 3 failures before opening circuit
- Default: 1-minute break duration
- Default: 30-second timeout for HTTP requests
- **NEW**: Retry configuration with exponential backoff
- Default: 3 retry attempts with 500ms base delay, max 5s delay

### 3. Enhanced UniqueKeyService
**File**: `Services/UniqueKeyService.cs`
- **NEW**: Integrated Polly retry policy with exponential backoff
- Integrated Polly circuit breaker pattern
- Combined retry + circuit breaker policies for optimal resilience
- Handles HTTP failures gracefully
- Provides detailed logging for both retry attempts and circuit breaker state changes
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
  "Resilience": {
    "HandledEventsAllowedBeforeBreaking": 3,
    "DurationOfBreak": "00:01:00",
    "Timeout": "00:00:30",
    "RetryCount": 3,
    "RetryBaseDelay": "00:00:00.500",
    "RetryMaxDelay": "00:00:05"
  }
}
```

## Resilience Behavior

### Retry Policy with Exponential Backoff
1. **First attempt**: Immediate execution
2. **Retry attempts**: 3 retries with exponential backoff (500ms, 1s, 2s)
3. **Maximum delay**: Capped at 5 seconds
4. **Triggers**: HTTP failures, timeouts, non-success status codes

### Circuit Breaker States
1. **Closed**: Normal operation, requests flow through (with retries on failure)
2. **Open**: Circuit is open, requests fail fast, fallback used (no retries)
3. **Half-Open**: Testing if service is back online

### Combined Policy Behavior
- **Normal operation**: Retry policy attempts up to 3 retries with exponential backoff
- **Multiple failures**: After configured failures, circuit breaker opens
- **Circuit open**: No retry attempts, immediate fallback
- **Circuit recovery**: Service attempts resume with retry protection

### Triggers
- HTTP request exceptions (`HttpRequestException`)
- Task cancellations (`TaskCanceledException`)
- Non-success HTTP status codes

### Fallback Strategy
When the key service is unavailable:
1. **First**: Retry attempts with exponential backoff (500ms → 1s → 2s delays)
2. **Then**: Circuit breaker opens after consecutive failures (3 by default)
3. **Finally**: ContentService automatically switches to GUID-based key generation
4. Application continues to function normally
5. Users can still create and share content

### Logging
- **Retry attempts**: Each retry is logged with attempt number and delay
- **Circuit breaker state changes**: Logged with details about duration and exceptions
- **Fallback key generation**: Logged as warnings when triggered
- **HTTP errors**: Logged with context and status codes

## Benefits

1. **Improved Reliability**: Application continues working even when key service fails
2. **Fast Failure**: No hanging requests when service is down (circuit breaker)
3. **Intelligent Retries**: Exponential backoff prevents overwhelming failing services
4. **Automatic Recovery**: Circuit breaker automatically tests for service recovery
5. **Graceful Degradation**: Fallback key generation maintains functionality
6. **Observability**: Comprehensive logging for monitoring and debugging
7. **Configurable Resilience**: Different settings for development vs production

## Configuration

### Production Settings (appsettings.json)
- **Circuit Breaker**: 3 failures before opening, 1-minute break duration, 30-second HTTP timeout
- **Retry**: 3 attempts with 500ms base delay, exponential backoff, max 5-second delay

### Development Settings (appsettings.Development.json)
- **Circuit Breaker**: 2 failures before opening (faster testing), 30-second break duration, 15-second HTTP timeout
- **Retry**: 2 attempts with 250ms base delay, exponential backoff, max 2-second delay

## Implementation Details

### Policy Combination
The service uses `Policy.WrapAsync(circuitBreakerPolicy, retryPolicy)` which means:
1. **Circuit Breaker wraps Retry**: When circuit is closed, retries happen normally
2. **Circuit Open**: When circuit is open, no retries are attempted (fail fast)
3. **Optimal Resilience**: Combines the benefits of both patterns without conflicts

### Exponential Backoff Formula
```
delay = min(baseDelay * 2^(attempt-1), maxDelay)
```
- Attempt 1: 500ms
- Attempt 2: 1000ms  
- Attempt 3: 2000ms
- Subsequent attempts capped at maxDelay (5000ms)

## Usage

The retry and circuit breaker patterns are automatically activated when:
1. Key service returns HTTP errors
2. Key service times out
3. Network connectivity issues occur
4. Any `HttpRequestException` or `TaskCanceledException`

No code changes are required in controllers or other services - the resilience is built into the infrastructure layer.
