#!/bin/bash

# Flutter Web Build Script for Vercel

set -e

echo "🚀 Starting Flutter web build for Vercel deployment..."

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter not found. Installing Flutter..."
    # This will be handled by Vercel's Flutter detection
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

echo "🔧 Building web app..."
flutter build web --release --web-renderer html --base-href /

echo "✅ Build completed successfully!"
echo "📁 Output directory: build/web"

# List built files for debugging
echo "📋 Built files:"
ls -la build/web/

echo "🎉 Ready for deployment!"