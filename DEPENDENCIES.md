# Simple PDF - Required Dependencies

This document lists all the dependencies needed for the Simple PDF application.

## Core Dependencies

Add these to your `pubspec.yaml` file under `dependencies:`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # PDF Viewing & Rendering
  pdfrx: ^1.0.0                          # Modern PDF viewer with PDFium
  
  # PDF Manipulation & Creation
  syncfusion_flutter_pdf: ^27.1.48       # PDF creation, split, merge, text extraction
  pdf_manipulator: ^1.1.0                # Additional PDF manipulation
  printing: ^5.13.4                      # PDF generation from widgets
  
  # Database
  hive: ^2.2.3                           # NoSQL key-value database
  hive_flutter: ^1.1.0                   # Hive Flutter integration
  
  # File Handling
  file_picker: ^8.1.6                    # File and folder picker
  path_provider: ^2.1.5                  # Access to filesystem directories
  permission_handler: ^11.3.1            # Permission management
  
  # HTTP & Networking
  dio: ^5.7.0                            # HTTP client for URL loading
  
  # UI Components
  flutter_speed_dial: ^7.0.0             # Floating action button menu
  photo_view: ^0.15.0                    # Image zoom/pan viewer
  
  # Utilities
  intl: ^0.19.0                          # Internationalization
  package_info_plus: ^8.1.0              # App version info
  url_launcher: ^6.3.1                   # Open URLs and folders

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Quality
  flutter_lints: ^5.0.0                  # Linting rules
  
  # App Icon Generation
  flutter_launcher_icons: ^0.14.1        # Generate app icons
  
  # Testing
  mockito: ^5.4.4                        # Mocking for tests
  build_runner: ^2.4.13                  # Code generation

# Hive Type Adapter Generation
dependency_overrides:
  # Add if needed for compatibility
```

## Installation Commands

After adding dependencies to `pubspec.yaml`, run:

```bash
# Get all dependencies
flutter pub get

# Generate Hive type adapters (after creating models)
flutter packages pub run build_runner build

# Generate app icons (after adding icon assets)
flutter pub run flutter_launcher_icons
```

## Platform-Specific Requirements

### Android
- Minimum SDK: 21 (Android 5.0)
- Permissions required:
  - `READ_EXTERNAL_STORAGE`
  - `WRITE_EXTERNAL_STORAGE`
  - `INTERNET`

### Linux
- No additional dependencies (filesystem access is direct)
- Ensure GTK3 development libraries are installed:
  ```bash
  sudo apt-get install libgtk-3-dev
  ```

## Optional Dependencies

These can be added later for enhanced functionality:

```yaml
# For Python script integration (security analysis)
process_run: ^1.2.0

# For SQLite (if needed instead of Hive)
sqflite: ^2.4.1
sqflite_common_ffi: ^2.3.4  # For Linux support

# For advanced image processing
image: ^4.3.0

# For cloud API integration (document conversion)
http: ^1.2.2
```

## Notes

1. **Syncfusion License**: `syncfusion_flutter_pdf` requires a license for commercial use. A free Community License is available for eligible projects.

2. **Version Compatibility**: Ensure all packages are compatible with your Flutter SDK version. Run `flutter pub outdated` to check for updates.

3. **Platform Support**: Not all packages support all platforms. The selected packages support Android and Linux as required.

4. **Large File Handling**: For PDFs larger than 50MB, consider implementing streaming and chunked loading to prevent memory issues.
