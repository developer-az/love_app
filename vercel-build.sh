#!/bin/bash

# Flutter Web Build Script for Vercel
set -e

echo "🚀 Starting Flutter web build for Vercel deployment..."

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter not found. Installing Flutter..."
    
    # Download and install Flutter
    curl -o flutter_linux.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
    tar xf flutter_linux.tar.xz
    
    # Add Flutter to PATH
    export PATH="$PWD/flutter/bin:$PATH"
    
    # Verify installation
    flutter doctor --android-licenses || true
    flutter doctor
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
