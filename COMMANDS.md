# Simple PDF - Command Reference

This document contains all the commands needed to set up and run the Simple PDF Flutter application.

## Initial Setup Commands

### 1. Install Flutter (if not already installed)

```bash
# Download Flutter SDK
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz

# Extract Flutter
tar xf flutter_linux_3.27.1-stable.tar.xz

# Add Flutter to PATH (add this to ~/.bashrc for persistence)
export PATH="$PATH:$HOME/flutter/bin"

# Reload bash configuration
source ~/.bashrc

# Verify installation
flutter doctor

# Accept Android licenses (if using Android)
flutter doctor --android-licenses
```

### 2. Install Linux Dependencies

```bash
# Install GTK3 development libraries
sudo apt-get update
sudo apt-get install libgtk-3-dev

# Install other required packages
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

### 3. Create Flutter Project

```bash
# Navigate to project directory
cd /media/sf_shared/code/simple_pdf

# Make setup script executable
chmod +x setup.sh

# Run setup script (this will create the Flutter project)
./setup.sh
```

**OR manually create the project:**

```bash
# Create Flutter project in current directory
flutter create --org com.nav.simplepdf --platforms android,linux .

# Enable platforms
flutter config --enable-linux-desktop
flutter config --enable-android

# Get dependencies
flutter pub get
```

## Development Commands

### Running the App

```bash
# Run on Linux
flutter run -d linux

# Run on Android (list devices first)
flutter devices
flutter run -d <device-id>

# Run in debug mode with hot reload
flutter run -d linux --debug

# Run in release mode
flutter run -d linux --release
```

### Building the App

```bash
# Build for Linux (release)
flutter build linux --release

# Build Android APK
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build for specific architecture
flutter build apk --target-platform android-arm64 --release
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/security_service_test.dart

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
xdg-open coverage/html/index.html
```

### Code Quality

```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format lib/

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade
```

### Code Generation

```bash
# Generate Hive type adapters
flutter packages pub run build_runner build

# Generate with conflict resolution
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate
flutter packages pub run build_runner watch
```

### App Icon Generation

```bash
# Generate app icons (after configuring flutter_launcher_icons)
flutter pub run flutter_launcher_icons
```

### Cleaning

```bash
# Clean build artifacts
flutter clean

# Clean and rebuild
flutter clean && flutter pub get && flutter run -d linux
```

## Dependency Management

### Adding Dependencies

```bash
# Add a package
flutter pub add package_name

# Add a dev dependency
flutter pub add --dev package_name

# Remove a package
flutter pub remove package_name
```

### Updating Dependencies

```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Upgrade specific package
flutter pub upgrade package_name
```

## Debugging Commands

### Device Management

```bash
# List all connected devices
flutter devices

# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>
```

### Logs and Debugging

```bash
# View logs
flutter logs

# Clear device logs
adb logcat -c  # Android only

# View device logs
adb logcat  # Android only

# Install APK manually
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Performance

```bash
# Profile app performance
flutter run --profile -d <device-id>

# Analyze app size
flutter build apk --analyze-size
flutter build appbundle --analyze-size
```

## Git Commands

### Initial Git Setup

```bash
# Initialize git (if not already done)
git init

# Add files
git add .

# Commit
git commit -m "Initial commit: Flutter project setup"

# Add remote (if needed)
git remote add origin <repository-url>

# Push
git push -u origin main
```

### Common Git Operations

```bash
# Check status
git status

# View changes
git diff

# Create branch
git checkout -b feature/new-feature

# Merge branch
git checkout main
git merge feature/new-feature

# Pull latest changes
git pull origin main
```

## Android Specific Commands

### Build Variants

```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build for specific ABI
flutter build apk --split-per-abi
```

### Signing

```bash
# Generate keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build signed APK (configure key.properties first)
flutter build apk --release
```

## Linux Specific Commands

### Desktop Integration

```bash
# Install built app system-wide (optional)
sudo cp -r build/linux/x64/release/bundle /opt/simple_pdf
sudo ln -s /opt/simple_pdf/simple_pdf /usr/local/bin/simple_pdf

# Create desktop entry
cat > ~/.local/share/applications/simple_pdf.desktop << EOF
[Desktop Entry]
Name=Simple PDF
Comment=PDF Viewer and Editor
Exec=/usr/local/bin/simple_pdf
Icon=/opt/simple_pdf/data/flutter_assets/assets/icon/icon.png
Terminal=false
Type=Application
Categories=Office;Viewer;
EOF
```

## Troubleshooting Commands

### Reset Flutter

```bash
# Reset Flutter cache
flutter clean
rm -rf ~/.pub-cache
flutter pub get
```

### Fix Common Issues

```bash
# Fix Gradle issues (Android)
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get

# Fix build_runner conflicts
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs

# Fix permission issues
chmod -R 755 android/
chmod +x android/gradlew
```

### Update Flutter

```bash
# Update Flutter SDK
flutter upgrade

# Switch Flutter channel
flutter channel stable
flutter upgrade
```

## Quick Reference

### Most Common Commands

```bash
# Setup
./setup.sh

# Run on Linux
flutter run -d linux

# Run on Android
flutter run

# Build release
flutter build linux --release
flutter build apk --release

# Test
flutter test

# Clean
flutter clean && flutter pub get
```

### File Locations

- **Linux build**: `build/linux/x64/release/bundle/`
- **Android APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Android App Bundle**: `build/app/outputs/bundle/release/app-release.aab`
- **Test coverage**: `coverage/lcov.info`

## Environment Variables

```bash
# Set Flutter path
export PATH="$PATH:$HOME/flutter/bin"

# Set Android SDK path
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Set Java home (if needed)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

Add these to `~/.bashrc` or `~/.zshrc` for persistence.
