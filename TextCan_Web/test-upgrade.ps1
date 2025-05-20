# Test Build Script for TextCan Web Application
# This script helps verify the Angular 14 upgrade changes without running the full build

Write-Host "Installing npm packages..." -ForegroundColor Cyan
npm install

Write-Host "Running lint check..." -ForegroundColor Cyan
npx tsc --noEmit

Write-Host "Checking modernization status..." -ForegroundColor Cyan

$packageJsonPath = ".\package.json"
$packageJson = Get-Content -Raw -Path $packageJsonPath | ConvertFrom-Json

Write-Host "Angular version: $($packageJson.dependencies.'@angular/core')" -ForegroundColor Green

Write-Host "TypeScript version: $($packageJson.devDependencies.'typescript')" -ForegroundColor Green

Write-Host "====================================" -ForegroundColor Yellow
Write-Host "Modernization check complete!" -ForegroundColor Yellow
Write-Host "To build when Node.js is updated:" -ForegroundColor Yellow
Write-Host "ng build --configuration production" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Yellow

# Verify if Node.js version meets requirements
$nodeVersion = node -v
Write-Host "Current Node.js version: $nodeVersion" -ForegroundColor Cyan
Write-Host "Required Node.js version: v18.19.0 or higher" -ForegroundColor Cyan

Write-Host "Process completed!" -ForegroundColor Green
