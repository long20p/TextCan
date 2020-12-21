# Start DB
Write-Host Start DynamoLocal DB
Start-Process java -WorkingDirectory "./TextCan_Server/TestDb" -ArgumentList "-D'java.library.path=./DynamoDBLocal_lib'", "-jar", "DynamoDBLocal.jar", "-sharedDb"

# Start key generation service
Write-Host Start key generation service
Start-Process py -WorkingDirectory "./TextCan_KeyGenerationService" -ArgumentList "manage.py", "runserver", "8083"

# Start API server
Write-Host Start API server
Start-Process dotnet -WorkingDirectory "./TextCan_Server/TextCan.Server" -ArgumentList "run"

# Start website
Write-Host Start website
Start-Process ng -WorkingDirectory "./TextCan_Web" -ArgumentList "serve"