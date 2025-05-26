# Start TextCan React Frontend
Write-Host "Starting TextCan React Frontend..." -ForegroundColor Cyan
Set-Location -Path "c:\GitRepo\FullStack\TextCan\TextCan_React"

# Install dependencies if node_modules doesn't exist
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
}

# Start the development server
Write-Host "Starting development server on http://localhost:4200" -ForegroundColor Green
npm run dev
