# Love App - Flutter Memory Sharing Application

Always follow these instructions first and only fallback to additional search and context gathering if the information here is incomplete or found to be incorrect.

## Overview
Love App is a cross-platform Flutter application for sharing and viewing special memories with photos, descriptions, dates, and locations. It supports Android, iOS, Web, Windows, Linux, and macOS platforms. The app uses local storage via SharedPreferences and has a romantic pink/coral theme.

## Quick Start - Development Setup

### Install Flutter SDK
**CRITICAL: Flutter installation takes 15-20 minutes. NEVER CANCEL during installation.**
```bash
# On Linux/macOS - Download Flutter stable release
cd /tmp
git clone https://github.com/flutter/flutter.git -b stable
export PATH="/tmp/flutter/bin:$PATH"

# On Windows - Use PowerShell
git clone https://github.com/flutter/flutter.git -b stable
$env:PATH += ";C:\tmp\flutter\bin"
```

### Verify Installation
```bash
flutter doctor --timeout 300
# NEVER CANCEL: This command takes 5-10 minutes to complete and may download additional SDKs
# Ignore warnings about missing platforms you don't need (e.g., Android Studio if targeting web only)
```

### Bootstrap Project
**CRITICAL: Build process takes 3-8 minutes. NEVER CANCEL. Set timeout to 15+ minutes.**
```bash
cd [project-root]

# Install dependencies - NEVER CANCEL: Takes 2-3 minutes
flutter pub get --timeout 300

# Create assets directories (required by setup.ps1 on Windows)
mkdir -p assets/fonts assets/images assets/icons

# Run setup script on Windows (downloads fonts - takes 1-2 minutes)
# powershell ./setup.ps1

# Analyze code for issues - Takes 30-60 seconds
flutter analyze --timeout 120

# Run tests - Takes 1-2 minutes
flutter test --timeout 300
```

## Building and Running

### Development (Debug Mode)
**CRITICAL: First build takes 5-8 minutes. NEVER CANCEL. Set timeout to 15+ minutes.**
```bash
# Web (fastest for development and testing UI changes)
flutter run -d chrome --timeout 900
# NEVER CANCEL: Initial build takes 5-8 minutes, subsequent hot reloads are instant

# Mobile (requires connected device or emulator)
flutter run --timeout 900

# Desktop - Linux (works in current environment)
flutter run -d linux --timeout 900

# Desktop - Windows (Windows hosts only)
flutter run -d windows --timeout 900

# Desktop - macOS (macOS hosts only)  
flutter run -d macos --timeout 900
```

### Production Builds
**CRITICAL: Production builds take 8-15 minutes per platform. NEVER CANCEL. Set timeout to 30+ minutes.**
```bash
# Web build - NEVER CANCEL: Takes 8-12 minutes
flutter build web --timeout 1800

# Android APK - NEVER CANCEL: Takes 10-15 minutes  
flutter build apk --timeout 1800

# Android App Bundle - NEVER CANCEL: Takes 10-15 minutes
flutter build appbundle --timeout 1800

# iOS (macOS only) - NEVER CANCEL: Takes 12-20 minutes
flutter build ios --timeout 2400

# Desktop builds - NEVER CANCEL: Takes 6-10 minutes each
flutter build linux --timeout 1800
flutter build windows --timeout 1800  
flutter build macos --timeout 1800
```

## Testing and Validation

### Automated Tests
```bash
# Unit and widget tests - NEVER CANCEL: Takes 1-3 minutes
flutter test --timeout 300

# Integration tests (if any exist)
flutter drive --target=test_driver/app.dart --timeout 600
```

### Manual Validation Scenarios
**ALWAYS perform these validation steps after making changes:**

#### Complete Memory Management Flow
1. **Launch Application**: 
   - Verify app starts without crashes or errors in console
   - Check that "Our Journey" title appears in app bar
   - Confirm floating action button (+ icon) is visible

2. **Create Memory Test**:
   - Tap floating action button to open AddMemoryScreen
   - Fill form: Title (e.g., "Beach Day"), Description (e.g., "Perfect sunny day"), Location (e.g., "Santa Monica")
   - Set date using date picker
   - Enter image URL (test with: https://picsum.photos/300/400) 
   - Tap save button
   - Verify return to HomeScreen with new memory card visible

3. **View Memory Details**:
   - Tap on a memory card from grid
   - Verify MemoryDetailScreen shows: image, title, date, location, description
   - Confirm back navigation works properly

4. **Data Persistence Test**:
   - Create 2-3 memories with different data
   - Close/kill application completely  
   - Restart application
   - Verify all memories are still displayed in grid

5. **UI Responsiveness**:
   - Test grid layout adapts to window resizing (desktop)
   - Verify smooth navigation transitions
   - Check image loading and error handling with invalid URLs
   - Test date formatting displays correctly (DD/MM/YYYY format)

#### Platform-Specific Testing

**Web Testing Steps**:
```bash
flutter run -d chrome --timeout 900
# Navigate to http://localhost:xxxx (port shown in terminal output)
# Complete memory management flow above
# Test: Refresh browser page - memories should persist
# Test: Open browser dev tools - check console for errors
# Test: Try different screen sizes/responsive behavior
```

**Desktop Testing Steps**:
```bash
flutter run -d linux --timeout 900  # or windows/macos
# Complete memory management flow above
# Test: Window resize - grid should adapt from 2 to 1 column on narrow windows
# Test: Keyboard navigation (tab, enter, escape)
# Test: Copy/paste in text fields
```

**Mobile Testing Steps** (if device/emulator available):
```bash
flutter run --timeout 900
# Complete memory management flow above
# Test: Portrait/landscape orientation
# Test: Touch gestures and scrolling
# Test: Keyboard appearance/dismissal
```

## Code Quality and CI Preparation

### Linting and Formatting
**ALWAYS run before committing - CI will fail otherwise:**
```bash
# Format code - Takes 10-30 seconds
dart format lib/ test/ --timeout 60

# Analyze code for issues - Takes 30-60 seconds  
flutter analyze --timeout 120

# Both commands must complete with no errors for CI to pass
```

### Build Verification
**Run these to ensure CI builds will succeed:**
```bash
# Verify all builds work - NEVER CANCEL: Takes 25-45 minutes total
flutter build web --timeout 1800
flutter build apk --timeout 1800
flutter build linux --timeout 1800  # Skip on non-Linux CI

# Check test coverage
flutter test --coverage --timeout 300
genhtml coverage/lcov.info -o coverage/html  # If coverage tools available
```

## Project Structure and Key Files

### Core Architecture
```
lib/
├── main.dart              # App entry point - always check after dependency changes
│                         # Contains: MySpecialApp, HomeScreen, MemoryCard widgets
├── models/
│   └── memory.dart       # Memory data model with JSON serialization
├── services/
│   └── memory_service.dart # SharedPreferences-based storage service
├── screens/
│   ├── add_memory_screen.dart    # Memory creation form with date picker
│   └── memory_detail_screen.dart # Full memory display screen
└── theme/
    └── app_theme.dart    # Coral/pink theme colors and styling constants

test/
└── widget_test.dart      # Basic app smoke test - extend after adding features
```

### Key Classes and Data Flow
- **Memory Model**: id, title, description, imageUrl, date, location
- **MemoryService**: CRUD operations using SharedPreferences JSON storage
- **HomeScreen**: Grid view of memory cards with floating action button
- **AddMemoryScreen**: Form with title, description, location, date picker, image URL
- **MemoryDetailScreen**: Full-screen memory display with image and details

### Configuration Files
- `pubspec.yaml`: Dependencies and assets - run `flutter pub get` after changes
- `analysis_options.yaml`: Linting rules - affects `flutter analyze` output
- Platform directories (`android/`, `ios/`, etc.): Platform-specific configurations
- `setup.ps1`: Windows PowerShell script to download Poppins font files

### Assets and Resources
```bash
# Create required asset directories (ALWAYS run this first)
mkdir -p assets/fonts assets/images assets/icons

# On Windows - Run PowerShell setup script to download fonts
powershell ./setup.ps1
# Downloads: Poppins-Regular.ttf, Poppins-Medium.ttf, Poppins-SemiBold.ttf, Poppins-Bold.ttf

# On Linux/macOS - Manually download fonts if needed:
curl -o assets/fonts/Poppins-Regular.ttf https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf
# Repeat for other font weights as needed
```

Asset structure after setup:
- `assets/fonts/`: Poppins font family (downloaded by setup.ps1)
- `assets/images/`: App images and user photos  
- `assets/icons/`: App icons and UI elements
- `web/manifest.json`: PWA configuration for web builds
- `web/icons/`: Web app icons (Icon-192.png, Icon-512.png, etc.)

## Common Development Workflows

### Adding New Features
1. **Modify data model** (if needed): Update `lib/models/memory.dart`
2. **Update service layer**: Modify `lib/services/memory_service.dart` 
3. **Create/update UI**: Add screens in `lib/screens/`
4. **Update theme**: Modify `lib/theme/app_theme.dart` for styling
5. **Test thoroughly**: Follow validation scenarios above
6. **Run quality checks**: `flutter analyze` and `dart format`

### Debugging Common Issues
- **State not updating**: Check if using `setState()` in StatefulWidget
- **Data not persisting**: Verify MemoryService is being called and await is used
- **Images not loading**: Check network permissions and URL validity
- **Build errors**: Run `flutter clean` then `flutter pub get`
- **Hot reload not working**: Full restart with `R` in terminal or IDE

### Code Quality Workflow
```bash
# Before every commit - NEVER SKIP:
dart format lib/ test/ --timeout 60    # Format code
flutter analyze --timeout 120          # Check for issues  
flutter test --timeout 300            # Run all tests

# If adding dependencies:
flutter pub get --timeout 300          # After updating pubspec.yaml
flutter pub upgrade --timeout 300      # To upgrade to latest versions
```

## Troubleshooting Common Issues

### Setup and Installation Issues
- **"flutter: command not found"**: Add Flutter/bin to PATH environment variable and restart terminal
- **"Blocked by DNS monitoring proxy"**: Network restrictions - try alternative install methods or work offline
- **Dart SDK download failures**: Delete cache folder and retry: `rm -rf ~/.flutter/bin/cache`

### Build and Run Issues
- **Gradle build failures**: Check `android/gradle.properties` memory settings (already configured for 8GB)
- **"Hot reload not available"**: Stop with `q` and restart with `flutter run`
- **Asset not found errors**: Ensure assets directories exist and run setup.ps1 on Windows
- **"flutter build" hangs**: NEVER CANCEL - builds can take 15+ minutes, use long timeouts
- **Version conflicts**: Run `flutter clean && flutter pub get` to reset build state

### Runtime Issues
- **Images not loading**: Check network connectivity and image URL validity
- **Data not persisting**: Verify SharedPreferences is being awaited properly in MemoryService
- **UI layout issues**: Check responsive design with different screen sizes/orientations
- **Navigation errors**: Ensure all screen widgets are properly imported and constructed

### Testing Issues
- **"SharedPreferences not found in tests"**: Use `SharedPreferences.setMockInitialValues({})` before tests
- **Widget tests timing out**: Increase timeout and ensure async operations are properly awaited
- **Test database isolation**: Each test should start with fresh SharedPreferences mock data

## Time Expectations
**Set appropriate timeouts for all operations - builds may be slow:**

- Flutter SDK install: 15-20 minutes  
- `flutter doctor`: 5-10 minutes
- `flutter pub get`: 2-3 minutes
- First debug build: 5-8 minutes per platform
- Production builds: 8-20 minutes per platform  
- Tests: 1-3 minutes
- Code analysis: 30-60 seconds
- Hot reload: Instant after initial build

**NEVER CANCEL long-running operations** - they will complete given enough time.

## Build Outputs and Locations
**Know where to find build artifacts:**
- Web: `build/web/` - Contains index.html and assets for hosting
- Android APK: `build/app/outputs/flutter-apk/app-release.apk`
- Android Bundle: `build/app/outputs/bundle/release/app-release.aab`
- Linux: `build/linux/x64/release/bundle/my_special_app`
- Windows: `build/windows/x64/runner/Release/my_special_app.exe`
- macOS: `build/macos/Build/Products/Release/my_special_app.app`

**Log and Debug Files:**
- Flutter logs: Check terminal output during `flutter run`
- Crash logs: Platform-specific locations (e.g., Android logcat)
- Build errors: Usually shown in terminal with file/line numbers

## Dependencies Summary
Key packages in use (check pubspec.yaml for versions):
- `shared_preferences`: Local data storage
- `intl`: Date formatting and internationalization  
- `cupertino_icons`: iOS-style icons
- `flutter_test`: Testing framework
- `flutter_lints`: Code quality rules

**Development dependencies:**
- `flutter_lints ^5.0.0`: Enforces code quality standards

Always run `flutter pub get` after modifying pubspec.yaml dependencies.