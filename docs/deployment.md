# TextCan Deployment Documentation

This document describes the Infrastructure as Code (IaC) deployment setup for the TextCan project using Azure Bicep.

## Overview

TextCan is deployed on Azure using a Bicep-based Infrastructure as Code approach. The deployment includes multiple Azure services that work together to form the complete TextCan solution.

## Architecture

The TextCan deployment consists of the following Azure resources:

- **Azure Cosmos DB**: Stores content data
- **Azure Key Vault**: Securely stores service credentials and connection strings
- **Azure Function App**: Hosts the Key Generation Service
- **Azure App Service**: Hosts the Content API
- **Azure Static Web App**: Hosts the Angular frontend UI
- **Azure Storage Account**: Supporting storage for Function App

## Deployment Structure

The deployment is organized in a modular structure in the `Azure` directory:

- `main.bicep`: The main deployment coordination file
- `modules/`: Directory containing individual service deployment modules
  - `cosmosdb.bicep`: Cosmos DB account and database deployment
  - `functionapp.bicep`: Function App deployment for Key Service
  - `keyvault.bicep`: Key Vault deployment
  - `keyvaultaccess.bicep`: Key Vault access policies
  - `storage.bicep`: Storage account deployment
  - `staticwebapp.bicep`: Static Web App deployment for UI
  - `webapp.bicep`: Web App deployment for Content API

## Deployment Parameters

The main deployment accepts the following parameters:

- `environment`: Deployment environment (dev, test, prod)
- `enableCosmosFreeTier`: Whether to use Cosmos DB free tier
- `location`: Azure region for deployment

## Resource Naming Convention

Resources follow a consistent naming convention:
- Prefix: `textcan`
- Suffix: Environment name (e.g., `dev`, `prod`)
- Resource type indicator (e.g., `func-` for Function Apps)

## Environment Configuration

The deployment manages environment configuration through:

1. Azure Key Vault secrets to store sensitive information
2. App Settings configured during deployment
3. Key Vault references in App Settings to securely access secrets

## Key Integration Points

- The Content API is configured to access Cosmos DB using a connection string stored in Key Vault
- The Content API calls the Key Generation Service using a URL and function key stored in Key Vault
- The Key Generation Service function URL contains a secure function key for authentication

## Outputs

The deployment provides the following outputs to simplify access to the deployed resources:
- Content API URL
- Key Service URL
- Static Web UI URL
- Cosmos DB Endpoint

## Security Features

- All services use system-assigned managed identities for authentication
- Key Vault access is granted only to required services
- HTTPS is enforced for all endpoints
- Function App keys secure access to serverless functions
