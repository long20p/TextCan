# Build and Test Script for TextCan Web Application

Write-Host "Installing npm packages..." -ForegroundColor Cyan
npm install

Write-Host "Building the application..." -ForegroundColor Cyan
ng build --configuration production

Write-Host "Checking for errors..." -ForegroundColor Cyan
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed with errors. Please check the log above." -ForegroundColor Red
    exit 1
}

Write-Host "Running tests..." -ForegroundColor Cyan
ng test --watch=false --browsers=ChromeHeadless

Write-Host "Process completed successfully!" -ForegroundColor Green
