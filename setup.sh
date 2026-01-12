#!/bin/bash

# Simple PDF - Flutter Project Setup Script
# This script sets up the Flutter project for Android and Linux platforms

set -e  # Exit on error

echo "=========================================="
echo "Simple PDF - Project Setup"
echo "=========================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not installed!"
    echo ""
    echo "Please install Flutter first:"
    echo "1. Visit: https://docs.flutter.dev/get-started/install/linux"
    echo "2. Download Flutter SDK"
    echo "3. Extract to a location (e.g., ~/development/flutter)"
    echo "4. Add to PATH: export PATH=\"\$PATH:\$HOME/development/flutter/bin\""
    echo "5. Run: flutter doctor"
    echo ""
    echo "Quick install commands:"
    echo "  cd ~"
    echo "  wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz"
    echo "  tar xf flutter_linux_3.27.1-stable.tar.xz"
    echo "  echo 'export PATH=\"\$PATH:\$HOME/flutter/bin\"' >> ~/.bashrc"
    echo "  source ~/.bashrc"
    echo "  flutter doctor"
    echo ""
    exit 1
fi

echo "✓ Flutter found: $(flutter --version | head -1)"
echo ""

# Navigate to project directory
cd "$(dirname "$0")"

# Check if this is already a Flutter project
if [ -f "pubspec.yaml" ]; then
    echo "✓ Flutter project already exists"
    echo ""
else
    echo "Creating Flutter project..."
    flutter create --org com.nav.simplepdf --platforms android,linux .
    echo "✓ Flutter project created"
    echo ""
fi

# Enable platforms
echo "Enabling platforms..."
flutter config --enable-linux-desktop
flutter config --enable-android
echo "✓ Platforms enabled"
echo ""

# Get dependencies
echo "Getting dependencies..."
flutter pub get
echo "✓ Dependencies installed"
echo ""

# Run Flutter doctor
echo "Running Flutter doctor..."
flutter doctor
echo ""

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review the generated pubspec.yaml"
echo "2. Add required dependencies (see DEPENDENCIES.md)"
echo "3. Run: flutter run -d linux (for Linux)"
echo "4. Run: flutter run -d <device-id> (for Android)"
echo ""
