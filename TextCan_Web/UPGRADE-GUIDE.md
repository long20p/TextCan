# TextCan Web Application Upgrade Guide

This guide outlines the steps taken to upgrade the TextCan Web application from Angular 7 to Angular 14.

## Summary of Changes

1. Updated package.json dependencies and devDependencies
2. Updated angular.json configuration (removed deprecated options like es5BrowserSupport and extractCss)
3. Updated TypeScript files with proper typing (added interfaces, proper return types, and type annotations)
4. Fixed HTML templates for Angular 14 compatibility (updated ngModel binding)
5. Updated environment files and polyfills
6. Fixed zone.js imports for Angular 14
7. Updated the app-routing.module.ts to use relativeLinkResolution
8. Modified testing files to work with the new Angular version

## Prerequisites

- Node.js v18.19.0 or higher (required by Angular 14)
- npm v8.0.0 or higher

## How to Complete the Upgrade

1. Install the required Node.js version (18.19.0 or higher)
```powershell
# Check your current Node.js version
node -v

# If you need to update Node.js, download the installer from https://nodejs.org/
```

2. Install dependencies
```powershell
npm install
```

3. Build the application
```powershell
ng build --configuration production
```

4. Run tests
```powershell
ng test --watch=false --browsers=ChromeHeadless
```

## Known Issues and Solutions

1. **Node.js version error**: If you see an error like "The Angular CLI requires a minimum Node.js version of v18.19", update your Node.js installation.

2. **HttpClient type issues**: The HttpClient in Angular 14 requires proper typing. We've updated the ContentService and ConfigService with appropriate interfaces.

3. **Form handling**: Angular 14 has stricter form typing. The MainComponent has been updated with proper FormGroup typing.

4. **NgModel binding**: Updated the read-only component to use one-way binding [ngModel] instead of two-way [(ngModel)] for read-only fields.

## Additional Modernization

1. **Security**: Consider adding Content Security Policy headers in your index.html
2. **Accessibility**: Ensure all form elements have proper labels and ARIA attributes
3. **Performance**: Consider implementing lazy loading for modules if the application grows

## Azure Static Web App Deployment

The GitHub workflow file has been updated to use the latest Azure Static Web Apps action:

```yaml
- name: Build And Deploy
  id: builddeploy
  uses: Azure/static-web-apps-deploy@v1
```

Make sure the workflow file has the correct working directory and build configuration.
