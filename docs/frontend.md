# TextCan Frontend Documentation

This document describes the frontend components of the TextCan project, located in the `TextCan_Web` directory.

## Overview

TextCan Web is an Angular-based frontend application that provides a user interface for the TextCan content service. It allows users to create and retrieve content via the TextCan API.

## Project Structure

The project follows standard Angular project structure:

- `src/`: Source code
  - `app/`: Application components, services, and modules
  - `assets/`: Static assets
  - `environments/`: Environment configuration files

## Key Components

### Services

The frontend interacts with the backend API using Angular services:

- `ContentService`: Provides methods to create and get content
  - `createContent(data)`: Posts new content to the API
  - `getContent(key)`: Retrieves content using a key

- `ConfigService`: Handles application configuration including API endpoint URLs

### Components

Based on the file structure, the application follows Angular component architecture, although specific component details are limited in the observation.

## Styling

The application uses:

- Bootstrap for layout and components
- SCSS for styling with global styles defined in `styles.scss`
- Custom Paper Kit CSS for UI components

## Configuration

The application uses Angular's environment configuration pattern to manage environment-specific settings.

## Build & Development

Built with Angular CLI, the project supports standard Angular commands:

- `ng serve`: Development server
- `ng build`: Production build
- `ng test`: Unit tests via Karma
- `ng e2e`: End-to-end tests via Protractor

## Deployment

The frontend is deployed as a static website to Azure Static Web Apps, as seen in the deployment files.
