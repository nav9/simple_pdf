import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionHelper {
  /// Request storage permissions for Android
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use different permissions
      if (await _isAndroid13OrHigher()) {
        // Request specific media permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
        ].request();
        
        return statuses.values.every((status) => status.isGranted);
      } else {
        // For older Android versions
        var status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    // Linux doesn't need permission requests
    return true;
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        return await Permission.photos.isGranted && 
               await Permission.videos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return true;
  }

  /// Request manage external storage permission (Android 11+)
  static Future<bool> requestManageStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return true;
  }

  /// Check if Android version is 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      // This is a simplified check - in production, use device_info_plus
      return false; // Default to false for now
    }
    return false;
  }

  /// Open app settings if permission is permanently denied
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Request internet permission (usually granted by default)
  static Future<bool> requestInternetPermission() async {
    // Internet permission is usually granted by default in AndroidManifest
    return true;
  }

  /// Check all required permissions
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'storage': await hasStoragePermission(),
      'internet': true, // Usually granted by default
    };
  }

  /// Request all required permissions
  static Future<bool> requestAllPermissions() async {
    final storageGranted = await requestStoragePermission();
    return storageGranted;
  }
}
