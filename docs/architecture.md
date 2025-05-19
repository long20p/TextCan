# TextCan Project Architecture Overview

This document provides a comprehensive architectural overview of the TextCan project, explaining how all components work together.

## System Architecture

TextCan is a cloud-based text sharing application with a microservices architecture. The system consists of three main components:

1. **Frontend Application**: An Angular-based single-page application
2. **Content API**: An ASP.NET Core RESTful API
3. **Key Generation Service**: A serverless function that generates unique keys

## Component Interaction Flow

The application follows this workflow:

1. **Content Creation**:
   - User inputs text in the frontend application
   - Frontend sends a request to the Content API
   - Content API requests a unique key from the Key Generation Service
   - Content API stores the text with the unique key in the database
   - The unique content URL is returned to the user

2. **Content Retrieval**:
   - User accesses a content URL with a unique key
   - Frontend extracts the key and sends a request to the Content API
   - Content API retrieves the content from the database
   - Content is displayed to the user

## Multi-Cloud Architecture

TextCan supports deployment to multiple cloud platforms with platform-specific implementations:

### Azure Implementation

- **Frontend**: Azure Static Web App
- **Content API**: Azure App Service with containerized ASP.NET Core application
- **Key Generation**: Azure Functions with .NET isolated worker
- **Database**: Azure Cosmos DB
- **Security**: Azure Key Vault for secrets management

### AWS Implementation

- **Frontend**: EC2 instance with http-server
- **Content API**: EC2 instance with ASP.NET Core application
- **Key Generation**: EC2 instance with Django application
- **Database**: Amazon DynamoDB
- **Security**: IAM roles for access control

## Data Model

The main data entity is the Content model:

- **Key**: Unique identifier for the content (string)
- **Text**: The actual content text (string)
- **ExpireAt**: Optional expiration timestamp (datetime)

## API Endpoints

- **POST /api/content/create**: Create new content
  - Request: `{ text: string, expireAt?: datetime }`
  - Response: `{ key: string, url: string }`

- **GET /api/content/get/{key}**: Retrieve content
  - Response: `{ text: string, expireAt?: datetime }`

## Security Architecture

- **Authentication**: N/A (public service)
- **Authorization**: N/A (public service)
- **Data Protection**: 
  - Azure: Key Vault for secret management
  - AWS: IAM roles for service access

## Infrastructure Management

The infrastructure is managed using Infrastructure as Code (IaC):

- **Azure**: Bicep templates for all resource deployment
- **AWS**: CloudFormation template for all resource deployment

## Continuous Integration/Deployment

GitHub Actions workflows automate the deployment process:

- Code changes trigger builds and tests
- Successful builds result in automatic deployments
- Different workflows handle different components

## Extensibility Points

The system is designed with several extensibility points:

1. **Multi-database support**: Abstracted repository layer supports different database providers
2. **Pluggable Key Generation**: External key generation service allows for custom key algorithms
3. **Cross-platform deployment**: IaC templates for multiple cloud providers

## Development Approach

The development process follows best practices:

- Modular architecture for independent component development
- Separation of concerns with clear service boundaries
- Infrastructure as Code for repeatable deployments
- CI/CD for automated testing and deployment
