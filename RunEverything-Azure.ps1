# Set host provider
$env:TextCan_HostProvider = "Azure"
$env:TextCan_Database__EndpointUrl = "https://api-server.documents.azure.com:443/"

# Start DB


# Start key generation service
Write-Host Start key generation service
Start-Process py -WorkingDirectory "./TextCan_KeyGenerationService" -ArgumentList "manage.py", "runserver", "8083"

# Start API server
Write-Host Start API server
Start-Process dotnet -WorkingDirectory "./TextCan_Server/TextCan.Server" -ArgumentList "run"

# Start website
Write-Host Start website
Start-Process ng -WorkingDirectory "./TextCan_Web" -ArgumentList "serve"