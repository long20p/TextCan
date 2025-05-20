# GitHub Workflows Documentation

This document describes the CI/CD workflows configured for the TextCan project using GitHub Actions.

## Overview

TextCan uses GitHub Actions workflows to automate building, testing, and deploying the various components of the application. The workflows are triggered based on changes to specific parts of the codebase, ensuring that each component can be developed and deployed independently.

## Workflow Files

The following workflow files are configured in the `.github/workflows` directory:

### 1. Key Service Serverless Function (`key_service_serverless.yml`)

**Purpose**: Builds and deploys the Key Generation Service Azure Function.

**Triggers**:
- Push to the `master` branch that modifies files in `KeyGenerationServiceServerless/` directory
- Manual trigger via workflow_dispatch

**Steps**:
1. Check out the repository
2. Set up .NET 8.0 environment
3. Restore NuGet dependencies
4. Build the Function App in Release configuration
5. Log in to Azure using service principal credentials
6. Deploy the function to Azure Function App

### 2. Static Web UI (`azure-static-web-ui.yml`)

**Purpose**: Builds and deploys the Angular frontend to Azure Static Web App.

**Triggers**:
- Push to the `master` branch that modifies files in `TextCan_Web/` directory
- Pull request events (open, sync, reopen, close) on the `master` branch
- Manual trigger via workflow_dispatch

**Steps**:
1. Check out the repository with submodules
2. Build and deploy the app using the Azure Static Web Apps action
3. Configure source directory, API location, and output location

### 3. Content API (`app-contentapi-textcan-dev.yml`)

**Purpose**: Builds and deploys the ASP.NET Core Content API.

**Steps**:
- Builds the .NET application
- Creates a Docker container
- Pushes to Azure Container Registry
- Deploys to Azure App Service

### 4. Master Key Generation Service (`master_key-generation-service.yml`)

**Purpose**: Additional workflow for the key generation service.

## Environment Secrets

The workflows use the following GitHub secrets:

- `AZURE_DEPLOY_CREDENTIALS`: Service principal credentials for Azure authentication
- `AZURE_DEPLOY_STATIC_WEB_UI_CREDENTIALS`: Static Web App deployment token

## Deployment Strategy

The workflows implement a CI/CD strategy with these characteristics:

1. **Component-Based Deployments**: Each component (API, UI, Function) is deployed independently based on changes to its code
2. **Branch Protection**: Deployments are primarily triggered by changes to the `master` branch
3. **Pull Request Integration**: Some workflows include PR triggers for preview environments
4. **Manual Override**: All workflows can be triggered manually using the workflow_dispatch event

## Pipeline Configuration

The deployment pipelines are configured to:

1. Build the application in a clean environment
2. Run any tests (where applicable)
3. Package the application appropriately (ZIP for functions, Docker for API)
4. Deploy to the target Azure service

## Best Practices Implemented

- Using specific versions of actions (e.g., `actions/checkout@v4`)
- Defining environment variables at the workflow level
- Using service principals with least privilege for Azure authentication
- Configuring conditional triggers based on file paths
