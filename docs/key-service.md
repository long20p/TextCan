# Key Generation Service Documentation

This document describes the Key Generation Service of the TextCan project, implemented as an Azure Functions serverless application.

## Overview

The Key Generation Service is a serverless Azure Function that generates unique keys for TextCan content. These keys are used to create unique URLs for accessing stored content.

## Implementation

The service is implemented in `KeyGenerationServiceServerless/KeyGenerator.cs` as an HTTP-triggered Azure Function.

### KeyGenerator Function

- **Function Type**: HTTP-triggered Azure Function
- **Method**: GET
- **Authorization Level**: Function

### Key Generation Algorithm

The service generates 8-character random strings using the following approach:
1. Uses a character set of a-z, A-Z, and 0-9
2. Randomly selects 8 characters to form a unique key
3. Returns the generated key as a JSON response

### Response Format

```json
{
  "key": "randomKey"
}
```

## Deployment

The Key Generation Service is deployed as an Azure Function App. The deployment is defined in `Azure/modules/functionapp.bicep`.

### Runtime Configuration

- **Runtime**: .NET
- **Function Runtime Version**: 4
- **OS**: Windows

### Security

Access to the function is controlled through function keys, which are required for API requests. The TextCan Server API service is configured to use these keys when requesting new unique keys.

## Integration with TextCan API

The TextCan Server API calls this service whenever a new unique key is needed for content creation. It communicates with this service using the configured endpoint and function key stored in the API's configuration.

## Alternative Implementation (Python/Django)

TextCan also provides an alternative implementation of the Key Generation Service built with Python and Django, located in the `TextCan_KeyGenerationService` directory. This implementation is primarily used for AWS deployments.

### Technology Stack

- **Framework**: Django 3.1.4
- **Language**: Python
- **Deployment**: EC2 instance (AWS)

### Implementation Details

The Python-based key service follows the same algorithm as the Azure Functions version:

1. Uses the same character set (a-z, A-Z, 0-9)
2. Generates an 8-character random string
3. Returns the key in identical JSON format

### Code Structure

- **Views**: `keygenerationservice/views.py` - Contains the `getkey` function that generates random keys
- **URLs**: 
  - `keygenerationservice/urls.py` - Maps the root URL to the key generation view
  - `TextCan_KeyGenerationService/urls.py` - Maps `/key/` path to the key generation app

### Endpoint

- **URL**: `/key/`
- **Method**: GET
- **Response**: JSON `{"key": "randomKey"}`

### Deployment (AWS)

When deployed in AWS:
- Runs as a standalone service on an EC2 instance
- Listens on port 8083
- Started using Django's built-in development server: `python3 manage.py runserver 0.0.0.0:8083`
- The API service is configured to connect to this endpoint via the AWS CloudFormation template
