# Manual Testing Guide for TextCan Upgrade

## Overview
This document outlines the steps to manually test the TextCan Web application after the Angular 14 upgrade.

## Prerequisites
- Node.js v18.19.0 or higher
- npm installed
- Angular CLI installed globally (`npm install -g @angular/cli`)

## Test Steps

### 1. Start the Development Server
```powershell
cd c:\GitRepo\FullStack\TextCan\TextCan_Web
npm install
ng serve
```

### 2. Test Basic Functionality
1. Open a browser and navigate to `http://localhost:4200/`
2. Verify that the main page loads correctly
3. Enter some text in the textarea
4. Click "Create" button
5. Verify that you're redirected to a page with a unique key
6. Verify that the text you entered appears in the readonly textarea

### 3. Test Error Handling
1. Try submitting an empty form (should be prevented by form validation)
2. Manually navigate to a non-existent key (e.g., `http://localhost:4200/invalid-key`)
3. Verify that appropriate error messages are displayed

### 4. Build the Production Version
```powershell
ng build --configuration production
```

Verify that the build process completes without errors and that the output files are generated in the `dist` folder.

### 5. Azure Static Web App Deployment Test

If you have the appropriate permissions, you can test the deployment by triggering the GitHub Actions workflow:

1. Make a small change to a file (e.g., add a comment)
2. Commit and push the change
3. Monitor the GitHub Actions workflow
4. Verify that the application is deployed correctly to Azure Static Web App

## Reporting Issues

If you encounter any issues during testing, please:
1. Take a screenshot of the error
2. Note the exact steps to reproduce
3. Check the browser console for any JavaScript errors
4. Document the environment (browser, OS, Node.js version)
