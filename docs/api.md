# TextCan API Documentation

This document describes the API components of the TextCan project, located in the `TextCan_Server` directory.

## Overview

The TextCan Server API is built with ASP.NET Core and provides endpoints for content management. It supports two different database backends: Azure Cosmos DB and AWS DynamoDB, configurable through the `HostProvider` setting.

## Project Structure

- **Controllers**: Contains the API endpoints
- **Models**: Contains data models
- **Services**: Business logic for the application
- **Repository**: Data access layer with implementations for both Azure and AWS
- **Configs**: Configuration classes

## Key Components

### ContentController

The main controller provides endpoints for creating and retrieving content:

- `POST api/content/create`: Creates new content
- `GET api/content/get/{uniqueId}`: Retrieves content by its unique ID

### Models

- `ContentModel`: Represents the content with text and optional expiration date

### Services

- `IContentService`: Interface for content management operations
- `ContentService`: Implementation of content service
- `IUniqueKeyService`: Interface for generating unique keys
- `UniqueKeyService`: Implementation of unique key generation

### Repository Layer

The repository layer follows a provider pattern with different implementations:

- **Azure**: Uses Cosmos DB for storage
  - `CosmosDbContext`
  - `CosmosContentRepository`
- **AWS**: Uses DynamoDB for storage
  - `DynamoDbContext`
  - `DynamoContentRepository`

### Configuration

- `DbConfig`: Database connection configuration (endpoint and key)
- `KeyServiceConfig`: Configuration for the external key generation service

## Database Schema

### Content
- `id`: Unique identifier
- `Key`: Unique key (partition key)
- `Text`: The actual content
- `ExpireAt`: Optional expiration date/time

## Deployment

The API is containerized using Docker with the provided `Dockerfile` and can be deployed to both Azure and AWS environments.
