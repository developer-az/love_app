# Deployment Guide

## Vercel Deployment

This Flutter web application is configured for deployment on Vercel with the following setup:

### Configuration Files

- `vercel.json` - Vercel deployment configuration
- `.vercelignore` - Files to exclude from deployment
- `build.sh` - Build script for Flutter web

### Deployment Process

1. **Framework Detection**: Vercel automatically detects this as a Flutter project
2. **Install Dependencies**: `flutter pub get`
3. **Build**: `flutter build web --release --web-renderer html --base-href /`
4. **Output**: Built files are served from `build/web/` directory

### Key Features

- **SPA Routing**: All routes redirect to `index.html` for client-side routing
- **Asset Caching**: Static assets cached for 1 year
- **Progressive Web App**: Configured with proper manifest and meta tags

### Troubleshooting

If you encounter 404 errors:

1. Ensure `vercel.json` is properly configured
2. Check that all asset paths are correct
3. Verify the build command completes successfully
4. Make sure Flutter version is compatible with Vercel

### Local Testing

To test the build locally:

```bash
flutter build web --release --web-renderer html
cd build/web
python -m http.server 8000
```

Then open `http://localhost:8000` in your browser.

### Environment Requirements

- Flutter SDK
- Dart SDK
- Web dependencies as specified in `pubspec.yaml`

### Deployment Status

The app should now deploy successfully to Vercel with:
- Proper SPA routing
- Optimized web assets
- Progressive Web App capabilities
- Correct base href configuration