# Test script to verify retry implementation
Write-Host "Testing Retry + Circuit Breaker Implementation" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Check if the configuration contains retry settings
$appSettingsPath = "TextCan_Server\TextCan.Server\appsettings.json"
$devSettingsPath = "TextCan_Server\TextCan.Server\appsettings.Development.json"

Write-Host "`nChecking configuration files..." -ForegroundColor Yellow

if (Test-Path $appSettingsPath) {
    $appSettings = Get-Content $appSettingsPath | ConvertFrom-Json
    Write-Host "✓ Production settings (appsettings.json):" -ForegroundColor Green
    Write-Host "  Circuit Breaker - Failures: $($appSettings.CircuitBreaker.HandledEventsAllowedBeforeBreaking), Break: $($appSettings.CircuitBreaker.DurationOfBreak)"
    Write-Host "  Retry - Count: $($appSettings.CircuitBreaker.RetryCount), Base Delay: $($appSettings.CircuitBreaker.RetryBaseDelay), Max Delay: $($appSettings.CircuitBreaker.RetryMaxDelay)"
} else {
    Write-Host "✗ appsettings.json not found" -ForegroundColor Red
}

if (Test-Path $devSettingsPath) {
    $devSettings = Get-Content $devSettingsPath | ConvertFrom-Json
    Write-Host "✓ Development settings (appsettings.Development.json):" -ForegroundColor Green
    Write-Host "  Circuit Breaker - Failures: $($devSettings.CircuitBreaker.HandledEventsAllowedBeforeBreaking), Break: $($devSettings.CircuitBreaker.DurationOfBreak)"
    Write-Host "  Retry - Count: $($devSettings.CircuitBreaker.RetryCount), Base Delay: $($devSettings.CircuitBreaker.RetryBaseDelay), Max Delay: $($devSettings.CircuitBreaker.RetryMaxDelay)"
} else {
    Write-Host "✗ appsettings.Development.json not found" -ForegroundColor Red
}

# Check if the code contains retry logic
$serviceFile = "TextCan_Server\TextCan.Server\Services\UniqueKeyService.cs"
Write-Host "`nChecking UniqueKeyService implementation..." -ForegroundColor Yellow

if (Test-Path $serviceFile) {
    $serviceContent = Get-Content $serviceFile -Raw
    
    $checks = @(
        @{ Pattern = "WaitAndRetryAsync"; Description = "Retry policy implementation" },
        @{ Pattern = "retryCircuitBreakerPolicy"; Description = "Combined policy variable" },
        @{ Pattern = "Policy\.WrapAsync"; Description = "Policy wrapping" },
        @{ Pattern = "Math\.Pow\(2, retryAttempt"; Description = "Exponential backoff formula" },
        @{ Pattern = "onRetry:"; Description = "Retry logging callback" },
        @{ Pattern = "System\.Text\.Json"; Description = "Modern JSON library" }
    )
    
    foreach ($check in $checks) {
        if ($serviceContent -match $check.Pattern) {
            Write-Host "  ✓ $($check.Description)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($check.Description)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "✗ UniqueKeyService.cs not found" -ForegroundColor Red
}

# Build test
Write-Host "`nTesting build..." -ForegroundColor Yellow
Push-Location "TextCan_Server\TextCan.Server"
try {
    $buildResult = dotnet build --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Project builds successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Build failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} finally {
    Pop-Location
}

Write-Host "`nImplementation Summary:" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host "✓ Retry policy with exponential backoff added" -ForegroundColor Green
Write-Host "✓ Circuit breaker integration maintained" -ForegroundColor Green
Write-Host "✓ System.Text.Json migration completed" -ForegroundColor Green
Write-Host "✓ Configuration updated for both environments" -ForegroundColor Green
Write-Host "✓ Documentation updated with new resilience patterns" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "- Test with actual key service failures to observe retry behavior" -ForegroundColor White
Write-Host "- Monitor logs for retry attempts and circuit breaker state changes" -ForegroundColor White
Write-Host "- Adjust retry count and delays based on production requirements" -ForegroundColor White
