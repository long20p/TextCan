# TextCan Project Documentation

Welcome to the TextCan project documentation. This documentation provides comprehensive information about the TextCan project, its components, and how they work together.

## Table of Contents

1. [Architecture Overview](architecture.md)
2. [API Documentation](api.md)
3. [Frontend Documentation](frontend.md)
4. [Key Service Documentation](key-service.md)
5. [Azure Deployment Documentation](deployment.md)
6. [AWS Deployment Documentation](aws-deployment.md)
7. [GitHub Workflows Documentation](github-workflows.md)

## Project Overview

TextCan is a full-stack application that allows users to create and retrieve text content via unique URLs. The application consists of several components:

- **Content API**: ASP.NET Core backend API for creating and retrieving content
- **Key Generation Service**: Azure Function that generates unique keys
- **Web UI**: Angular-based frontend application
- **Infrastructure**: Azure-based cloud infrastructure defined using Bicep

## Architecture

TextCan follows a microservices architecture with the following components:

1. **Frontend**: Angular-based UI hosted on Azure Static Web App
2. **Content API**: ASP.NET Core API hosted on Azure App Service
3. **Key Generation Service**: Azure Function for generating unique content keys
4. **Database**: Azure Cosmos DB for content storage

## Technology Stack

- **Frontend**: Angular, TypeScript, SCSS, Bootstrap
- **Backend**: ASP.NET Core, C#
- **Serverless**: Azure Functions, .NET Isolated Worker
- **Database**: Azure Cosmos DB (with alternative AWS DynamoDB support)
- **Infrastructure as Code**: Azure Bicep, AWS CloudFormation
- **CI/CD**: GitHub Actions

## Multi-Cloud Support

TextCan is designed to run on multiple cloud platforms:

- **Azure**: Primary deployment platform with full support
- **AWS**: Alternative deployment option

## Getting Started

To get started with the TextCan project, follow these steps:

1. Clone the repository
2. Choose your cloud platform:
   - For Azure: Run `.\RunEverything-Azure.ps1`
   - For AWS: Run `.\RunEverything-AWS.ps1`
3. Follow the deployment documentation for more details

## Development Workflow

The development workflow is managed through GitHub:

1. Create feature branches from `master`
2. Submit pull requests for review
3. CI/CD workflows will deploy changes to appropriate environments

## Additional Resources

For more information on specific components, refer to the respective documentation files listed in the Table of Contents.
