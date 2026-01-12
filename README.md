# Simple PDF

A comprehensive Flutter PDF viewer and editor application for Android and Linux platforms.

## Features

### PDF Viewing
- Load PDF files from filesystem
- Zoom and pan support
- Fullscreen mode
- Color inversion for dark mode
- Intelligent PDF dark mode rendering

### Security Analysis
- Automatic PDF threat detection
- Categorized security warnings (Critical, High, Medium, Low)
- Detection of JavaScript, embedded files, external links, and suspicious structures
- User-friendly threat explanations

### PDF Manipulation
- **Split PDFs**: Select specific pages to extract into new documents
- **Merge PDFs**: Combine pages from multiple PDF files
- Thumbnail preview for page selection
- Custom save location with folder browser

### Text & Image Extraction
- Extract text from PDF pages
- Extract embedded images
- Save to filesystem or database
- Smart permission handling
- Recent folder history

### Document Conversion
- PDF to TXT
- TXT to PDF
- Future support for DOC/DOCX/PPT/XLS formats

### Advanced Features
- Load PDFs from URLs
- Database storage for URL-loaded files
- Large file handling with size warnings
- Customizable scrollbar position (Android)
- Light and dark themes
- Comprehensive help documentation

## Getting Started

### Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   - Install from: https://docs.flutter.dev/get-started/install/linux
   - Add Flutter to your PATH

2. **Platform Requirements**
   - **Android**: Android SDK, API level 21+
   - **Linux**: GTK3 development libraries
     ```bash
     sudo apt-get install libgtk-3-dev
     ```

### Installation

1. Clone the repository:
   ```bash
   cd /media/sf_shared/code/simple_pdf
   ```

2. Run the setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. Add dependencies to `pubspec.yaml` (see `DEPENDENCIES.md`)

4. Get dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

**On Linux:**
```bash
flutter run -d linux
```

**On Android:**
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Building the App

**Linux:**
```bash
flutter build linux --release
```

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

## Project Structure

```
simple_pdf/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/                      # Data models
│   ├── services/                    # Business logic
│   ├── screens/                     # UI screens
│   ├── widgets/                     # Reusable widgets
│   ├── utils/                       # Utilities
│   └── database/                    # Database adapters
├── assets/
│   └── icon/                        # App icon
├── android/                         # Android configuration
├── linux/                           # Linux configuration
├── test/                           # Unit tests
├── setup.sh                        # Setup script
├── DEPENDENCIES.md                 # Dependency documentation
└── README.md                       # This file
```

## Configuration

### App Icon

1. Add your icon to `assets/icon/icon.png` (1024x1024)
2. Configure `flutter_launcher_icons` in `pubspec.yaml`
3. Run:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Permissions (Android)

The app requires the following permissions:
- `READ_EXTERNAL_STORAGE` - Read PDF files
- `WRITE_EXTERNAL_STORAGE` - Save extracted content
- `INTERNET` - Load PDFs from URLs

These are configured in `android/app/src/main/AndroidManifest.xml`

## Development

### Running Tests

```bash
flutter test
```

### Code Generation (Hive Adapters)

```bash
flutter packages pub run build_runner build
```

### Linting

```bash
flutter analyze
```

## Usage Guide

### Opening a PDF

1. Launch the app
2. Tap "Open PDF from Device" or "Load PDF from URL"
3. If security analysis is enabled, review any detected threats
4. Choose to proceed or cancel

### Splitting a PDF

1. Open a PDF
2. Tap the menu icon → "Split PDF"
3. Select pages using checkboxes
4. Choose save location
5. Tap "Save" to create the new PDF

### Merging PDFs

1. From home screen, tap "Merge PDFs"
2. Select multiple PDF files
3. Choose pages from each file
4. Arrange pages in desired order
5. Choose save location and confirm

### Extracting Content

1. Open a PDF
2. Tap menu → "Extract Text" or "Extract Images"
3. Choose to save to filesystem or database
4. Select save location if saving to filesystem

### Settings

Access via home screen menu:
- **Theme**: Toggle between light and dark
- **Scrollbar Position** (Android): Left, Right, or Disabled
- **Recent Folders**: Manage import/export folder history
- **Clear Cache**: Remove cached URL PDFs

## Troubleshooting

### Flutter not found
Ensure Flutter is in your PATH:
```bash
export PATH="$PATH:$HOME/flutter/bin"
source ~/.bashrc
```

### Permission denied on Android
Grant storage permissions in device settings or when prompted by the app.

### Large PDF files crash the app
The app will warn about files larger than 50MB. For very large files, consider splitting them first.

### Build errors
Run:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Credits

- **Developer**: Nav
- **Flutter**: Google
- **PDF Libraries**: Syncfusion, PDFium

## Version

Current version: 1.0.0

For detailed version history, see the About screen in the app.
