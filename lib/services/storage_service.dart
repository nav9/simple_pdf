import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/permissions.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class StorageService {
  final DatabaseService _dbService = DatabaseService();
  
  /// Pick a file from the filesystem
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? initialDirectory,
  }) async {
    // Request permission
    final hasPermission = await PermissionHelper.requestStoragePermission();
    if (!hasPermission) {
      throw Exception(Constants.errorPermissionDenied);
    }
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      initialDirectory: initialDirectory,
    );
    
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      
      // Add to recent folders
      final directory = File(filePath).parent.path;
      await _dbService.addRecentFolder(directory, isImport: true);
      
      return filePath;
    }
    
    return null;
  }
  
  /// Pick multiple files
  Future<List<String>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    final hasPermission = await PermissionHelper.requestStoragePermission();
    if (!hasPermission) {
      throw Exception(Constants.errorPermissionDenied);
    }
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );
    
    if (result != null) {
      return result.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();
    }
    
    return [];
  }
  
  /// Pick a directory for saving
  Future<String?> pickDirectory({String? initialDirectory}) async {
    final hasPermission = await PermissionHelper.requestStoragePermission();
    if (!hasPermission) {
      throw Exception(Constants.errorPermissionDenied);
    }
    
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      initialDirectory: initialDirectory,
    );
    
    if (selectedDirectory != null) {
      // Add to recent folders
      await _dbService.addRecentFolder(selectedDirectory, isImport: false);
    }
    
    return selectedDirectory;
  }
  
  /// Save file to a specific directory
  Future<String> saveFile({
    required String fileName,
    required List<int> bytes,
    String? directory,
  }) async {
    String targetDirectory;
    
    if (directory != null) {
      targetDirectory = directory;
    } else {
      // Use app documents directory as fallback
      final appDir = await getApplicationDocumentsDirectory();
      targetDirectory = appDir.path;
    }
    
    // Check if we have write permission
    final testFile = File('$targetDirectory/.test');
    try {
      await testFile.writeAsString('test');
      await testFile.delete();
    } catch (e) {
      // No write permission, use app directory
      final appDir = await getApplicationDocumentsDirectory();
      targetDirectory = appDir.path;
    }
    
    final filePath = '$targetDirectory/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    
    // Add to recent folders
    await _dbService.addRecentFolder(targetDirectory, isImport: false);
    
    return filePath;
  }
  
  /// Get app documents directory
  Future<String> getAppDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  /// Get app cache directory
  Future<String> getAppCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }
  
  /// Create directory if it doesn't exist
  Future<void> ensureDirectoryExists(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
  
  /// Check if file exists
  Future<bool> fileExists(String path) async {
    final file = File(path);
    return await file.exists();
  }
  
  /// Delete file
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  /// Get file size
  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
  
  /// Copy file
  Future<String> copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final destinationFile = await sourceFile.copy(destinationPath);
    return destinationFile.path;
  }
  
  /// Move file
  Future<String> moveFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final destinationFile = await sourceFile.rename(destinationPath);
    return destinationFile.path;
  }
  
  /// Get recent import folders
  List<String> getRecentImportFolders() {
    return _dbService.getRecentFolders(isImport: true);
  }
  
  /// Get recent export folders
  List<String> getRecentExportFolders() {
    return _dbService.getRecentFolders(isImport: false);
  }
  
  /// Open folder in file manager (platform-specific)
  Future<void> openFolder(String path) async {
    // This is a placeholder - actual implementation would use url_launcher
    // or platform-specific code to open the folder
    if (Platform.isLinux) {
      await Process.run('xdg-open', [path]);
    } else if (Platform.isAndroid) {
      // Android doesn't have a direct way to open folders
      // Would need to use intent or file manager app
      throw UnimplementedError('Opening folders on Android requires additional implementation');
    }
  }
}
