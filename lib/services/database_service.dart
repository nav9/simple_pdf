import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pdf_document.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  // Get Hive boxes
  Box get _settingsBox => Hive.box(Constants.settingsBox);
  Box get _recentFoldersBox => Hive.box(Constants.recentFoldersBox);
  Box get _pdfMetadataBox => Hive.box(Constants.pdfMetadataBox);
  Box get _cachedPdfsBox => Hive.box(Constants.cachedPdfsBox);
  
  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
  
  Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }
  
  // Recent folders operations
  Future<void> addRecentFolder(String folderPath, {bool isImport = true}) async {
    final key = isImport ? Constants.importFoldersKey : Constants.exportFoldersKey;
    final folders = getRecentFolders(isImport: isImport);
    
    // Remove if already exists
    folders.remove(folderPath);
    
    // Add to beginning
    folders.insert(0, folderPath);
    
    // Keep only max recent folders
    if (folders.length > Constants.maxRecentFolders) {
      folders.removeRange(Constants.maxRecentFolders, folders.length);
    }
    
    await _recentFoldersBox.put(key, folders);
  }
  
  List<String> getRecentFolders({bool isImport = true}) {
    final key = isImport ? Constants.importFoldersKey : Constants.exportFoldersKey;
    final folders = _recentFoldersBox.get(key, defaultValue: <String>[]);
    return List<String>.from(folders);
  }
  
  Future<void> removeRecentFolder(String folderPath, {bool isImport = true}) async {
    final key = isImport ? Constants.importFoldersKey : Constants.exportFoldersKey;
    final folders = getRecentFolders(isImport: isImport);
    folders.remove(folderPath);
    await _recentFoldersBox.put(key, folders);
  }
  
  Future<void> clearRecentFolders({bool? isImport}) async {
    if (isImport == null) {
      await _recentFoldersBox.clear();
    } else {
      final key = isImport ? Constants.importFoldersKey : Constants.exportFoldersKey;
      await _recentFoldersBox.delete(key);
    }
  }
  
  // PDF metadata operations
  Future<void> savePdfMetadata(PdfDocument document) async {
    await _pdfMetadataBox.put(document.id, document.toJson());
  }
  
  PdfDocument? getPdfMetadata(String id) {
    final json = _pdfMetadataBox.get(id);
    if (json != null) {
      return PdfDocument.fromJson(Map<String, dynamic>.from(json));
    }
    return null;
  }
  
  List<PdfDocument> getAllPdfMetadata() {
    final documents = <PdfDocument>[];
    for (final key in _pdfMetadataBox.keys) {
      final json = _pdfMetadataBox.get(key);
      if (json != null) {
        documents.add(PdfDocument.fromJson(Map<String, dynamic>.from(json)));
      }
    }
    // Sort by last accessed, most recent first
    documents.sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
    return documents;
  }
  
  Future<void> deletePdfMetadata(String id) async {
    await _pdfMetadataBox.delete(id);
  }
  
  Future<void> updateLastAccessed(String id) async {
    final document = getPdfMetadata(id);
    if (document != null) {
      final updated = document.copyWith(lastAccessed: DateTime.now());
      await savePdfMetadata(updated);
    }
  }
  
  // Cached PDFs operations (for URL-loaded PDFs)
  Future<void> cachePdf(String url, List<int> bytes) async {
    await _cachedPdfsBox.put(url, bytes);
  }
  
  List<int>? getCachedPdf(String url) {
    final data = _cachedPdfsBox.get(url);
    if (data != null) {
      return List<int>.from(data);
    }
    return null;
  }
  
  Future<void> deleteCachedPdf(String url) async {
    await _cachedPdfsBox.delete(url);
  }
  
  Future<void> clearCache() async {
    await _cachedPdfsBox.clear();
    await _pdfMetadataBox.clear();
  }
  
  // Get cache size
  int getCacheSize() {
    int totalSize = 0;
    for (final key in _cachedPdfsBox.keys) {
      final data = _cachedPdfsBox.get(key);
      if (data is List) {
        totalSize += data.length;
      }
    }
    return totalSize;
  }
  
  String getFormattedCacheSize() {
    final size = getCacheSize();
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
