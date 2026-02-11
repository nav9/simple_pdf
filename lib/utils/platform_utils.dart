import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if running on web
  static bool get isWeb => kIsWeb;

  /// Check if running on mobile (Android or iOS)
  static bool get isMobile => isAndroid || isIOS;

  /// Check if running on desktop (Linux, Windows, or macOS)
  static bool get isDesktop => isLinux || isWindows || isMacOS;

  /// Get platform name
  static String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isLinux) return 'Linux';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  /// Check if pdfrx is available on current platform
  /// pdfrx supports Android, iOS, Linux, macOS, Windows, Web
  static bool get isPdfrxAvailable => true;

  /// Check if easy_pdf_viewer is available on current platform
  /// easy_pdf_viewer primarily supports Android and iOS
  static bool get isEasyPdfViewerAvailable => isMobile;

  /// Get available PDF viewer packages for current platform
  static List<String> get availablePdfViewers {
    final viewers = <String>[];
    if (isPdfrxAvailable) viewers.add('pdfrx');
    if (isEasyPdfViewerAvailable) viewers.add('easy_pdf_viewer');
    return viewers;
  }

  /// Get default PDF viewer for current platform
  static String get defaultPdfViewer {
    if (isPdfrxAvailable) return 'pdfrx';
    if (isEasyPdfViewerAvailable) return 'easy_pdf_viewer';
    return 'pdfrx'; // fallback
  }
}
