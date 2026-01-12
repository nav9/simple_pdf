import 'dart:io';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../models/pdf_document.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class PdfService {
  final DatabaseService _dbService = DatabaseService();
  final Dio _dio = Dio();
  
  /// Load PDF from file path
  Future<PdfDocument> loadFromFile(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      throw Exception(Constants.errorFileNotFound);
    }
    
    final fileSize = await file.length();
    final fileName = file.path.split('/').last;
    
    final document = PdfDocument(
      id: const Uuid().v4(),
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
      isFromUrl: false,
      isCached: false,
    );
    
    // Save metadata
    await _dbService.savePdfMetadata(document);
    
    return document;
  }
  
  /// Load PDF from URL
  Future<PdfDocument> loadFromUrl(String url, {
    Function(int, int)? onProgress,
  }) async {
    try {
      // Check if already cached
      final cached = _dbService.getCachedPdf(url);
      if (cached != null) {
        return _createDocumentFromCache(url, cached);
      }
      
      // Download PDF
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onProgress,
      );
      
      if (response.data == null) {
        throw Exception(Constants.errorNetworkFailure);
      }
      
      final bytes = response.data!;
      final fileSize = bytes.length;
      
      // Check file size
      if (fileSize > Constants.maxFileSize) {
        throw Exception(Constants.errorFileTooLarge);
      }
      
      // Cache the PDF
      await _dbService.cachePdf(url, bytes);
      
      return _createDocumentFromCache(url, bytes);
    } catch (e) {
      if (e is DioException) {
        throw Exception(Constants.errorNetworkFailure);
      }
      rethrow;
    }
  }
  
  PdfDocument _createDocumentFromCache(String url, List<int> bytes) {
    final fileName = url.split('/').last.split('?').first;
    
    final document = PdfDocument(
      id: const Uuid().v4(),
      fileName: fileName.isNotEmpty ? fileName : 'downloaded.pdf',
      fileUrl: url,
      fileSize: bytes.length,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
      isFromUrl: true,
      isCached: true,
    );
    
    _dbService.savePdfMetadata(document);
    
    return document;
  }
  
  /// Get recent PDFs
  Future<List<PdfDocument>> getRecentPdfs({int limit = 10}) async {
    final all = _dbService.getAllPdfMetadata();
    return all.take(limit).toList();
  }
  
  /// Update last accessed time
  Future<void> updateLastAccessed(String documentId) async {
    await _dbService.updateLastAccessed(documentId);
  }
  
  /// Delete PDF metadata
  Future<void> deletePdfMetadata(String documentId) async {
    await _dbService.deletePdfMetadata(documentId);
  }
  
  /// Check if file size is too large
  bool isFileTooLarge(int fileSize) {
    return fileSize > Constants.maxFileSize;
  }
  
  /// Check if file size should show warning
  bool shouldWarnFileSize(int fileSize) {
    return fileSize > Constants.warningFileSize;
  }
  
  /// Get file size warning message
  String getFileSizeWarning(int fileSize) {
    final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
    if (isFileTooLarge(fileSize)) {
      return 'File size ($sizeMB MB) exceeds the maximum limit of ${Constants.maxFileSize / (1024 * 1024)} MB';
    } else if (shouldWarnFileSize(fileSize)) {
      return 'Large file ($sizeMB MB) may take longer to load and process';
    }
    return '';
  }
}
