# TextCan Full Stack - Choose Frontend
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("angular", "react")]
    [string]$Frontend = "react"
)

# Set host provider
$env:TextCan_HostProvider = "Azure"
$env:TextCan_Database__EndpointUrl = "https://localhost:8081"

Write-Host "Starting TextCan Full Stack with $Frontend frontend..." -ForegroundColor Cyan

# Start DB
Write-Host "Starting Cosmos DB emulator..." -ForegroundColor Yellow
Start-Process -FilePath "C:\Program Files\Azure Cosmos DB Emulator\Microsoft.Azure.Cosmos.Emulator.exe" -WindowStyle Minimized

# Start key generation service
Write-Host "Starting key generation service..." -ForegroundColor Yellow
Start-Process py -WorkingDirectory "./TextCan_KeyGenerationService" -ArgumentList "manage.py", "runserver", "8083" -WindowStyle Minimized

# Start API server
Write-Host "Starting API server..." -ForegroundColor Yellow
Start-Process dotnet -WorkingDirectory "./TextCan_Server/TextCan.Server" -ArgumentList "run" -WindowStyle Minimized

# Wait a moment for services to start
Start-Sleep -Seconds 3

# Start website based on chosen frontend
if ($Frontend -eq "angular") {
    Write-Host "Starting Angular frontend..." -ForegroundColor Green
    Start-Process ng -WorkingDirectory "./TextCan_Web" -ArgumentList "serve"
} else {
    Write-Host "Starting React frontend..." -ForegroundColor Green
    Start-Process npm -WorkingDirectory "./TextCan_React" -ArgumentList "run", "dev"
}

Write-Host "All services started!" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:4201" -ForegroundColor Green
Write-Host "API: http://localhost:5000" -ForegroundColor Green
Write-Host "Key Service: http://localhost:8083" -ForegroundColor Green
