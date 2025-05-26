# TextCan React Frontend

This is the React TypeScript version of the TextCan frontend application, converted from Angular.

## Features

- **Simple text sharing**: Create and share text snippets via unique URLs
- **Clean UI**: Bootstrap-based responsive design
- **TypeScript**: Full type safety and modern development experience
- **Fast**: Built with Vite for optimal development and build performance

## Architecture

- **React 18** with functional components and hooks
- **TypeScript** for type safety
- **React Router** for client-side routing
- **Bootstrap 5** for styling
- **Vite** as build tool

## Project Structure

```
src/
  components/
    MainComponent.tsx      # Home page with text input form
    ReadOnlyComponent.tsx  # Read-only view for shared content
  services/
    config.service.ts      # Configuration management
    content.service.ts     # API communication
  App.tsx                  # Main app component with routing
  main.tsx                 # Application entry point
  styles.scss              # Global styles
public/
  assets/
    settings.json          # API configuration
```

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Installation

```powershell
cd TextCan_React
npm install
```

### Development

```powershell
npm run dev
```

This starts the development server at `http://localhost:4201`.

### Build for Production

```powershell
npm run build
```

The built files will be in the `dist/` directory.

### Preview Production Build

```powershell
npm run preview
```

## Configuration

The application loads its configuration from `public/assets/settings.json`:

```json
{
  "baseUrl": "https://your-api-url.com/"
}
```

## API Integration

The app communicates with the TextCan .NET Core API:

- `POST /api/content/create` - Create new content
- `GET /api/content/get/{key}` - Retrieve content by key

## Deployment

This React app can be deployed to:

- **Azure Static Web Apps** (recommended)
- **Netlify**
- **Vercel** 
- Any static hosting service

For Azure Static Web Apps, use the build output from the `dist/` directory.

## Differences from Angular Version

- Uses modern React hooks instead of Angular services
- Simplified state management with useState
- Native fetch API instead of HttpClient
- React Router instead of Angular Router
- Vite instead of Angular CLI for build tooling

## Migration Notes

All functionality from the Angular version has been preserved:

✅ Text input and creation  
✅ Unique URL generation and navigation  
✅ Read-only content viewing  
✅ Bootstrap styling  
✅ API configuration  
✅ Error handling  
✅ Loading states  

The React version is simpler and has fewer dependencies while maintaining the same user experience.
