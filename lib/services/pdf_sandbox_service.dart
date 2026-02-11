import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/pdf_file_model.dart';
import 'encryption_service.dart';

class PdfSandboxService {
  static final PdfSandboxService _instance = PdfSandboxService._internal();
  factory PdfSandboxService() => _instance;
  PdfSandboxService._internal();

  final _encryptionService = EncryptionService();

  /// Get the app's private PDF storage directory
  Future<Directory> getPdfStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(path.join(appDir.path, 'pdfs'));
    
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    
    return pdfDir;
  }

  /// Get the app's private thumbnail storage directory
  Future<Directory> getThumbnailStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbDir = Directory(path.join(appDir.path, 'thumbnails'));
    
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    
    return thumbDir;
  }

  /// Copy PDF file to sandboxed storage
  Future<String> copyPdfToSandbox(String sourcePath, String pdfId,
      {bool encrypt = false, String? encryptionKey}) async {
    final pdfDir = await getPdfStorageDirectory();
    final fileName = '$pdfId.pdf';
    final destPath = path.join(pdfDir.path, fileName);
    
    final sourceFile = File(sourcePath);
    final bytes = await sourceFile.readAsBytes();
    
    final destFile = File(destPath);
    
    if (encrypt && encryptionKey != null) {
      // Encrypt the PDF data
      final encryptedBytes = _encryptionService.encryptFile(bytes, encryptionKey);
      await destFile.writeAsBytes(encryptedBytes);
    } else {
      await destFile.writeAsBytes(bytes);
    }
    
    return destPath;
  }

  /// Save PDF bytes to sandboxed storage
  Future<String> savePdfBytesToSandbox(Uint8List bytes, String pdfId,
      {bool encrypt = false, String? encryptionKey}) async {
    final pdfDir = await getPdfStorageDirectory();
    final fileName = '$pdfId.pdf';
    final destPath = path.join(pdfDir.path, fileName);
    
    final destFile = File(destPath);
    
    if (encrypt && encryptionKey != null) {
      // Encrypt the PDF data
      final encryptedBytes = _encryptionService.encryptFile(bytes, encryptionKey);
      await destFile.writeAsBytes(encryptedBytes);
    } else {
      await destFile.writeAsBytes(bytes);
    }
    
    return destPath;
  }

  /// Read PDF from sandbox (with decryption if needed)
  Future<Uint8List> readPdfFromSandbox(PdfFileModel pdf) async {
    final file = File(pdf.filePath);
    final bytes = await file.readAsBytes();
    
    if (pdf.isEncrypted && pdf.encryptionKey != null) {
      return _encryptionService.decryptFile(bytes, pdf.encryptionKey!);
    }
    
    return bytes;
  }

  /// Get temporary file path for viewing (decrypted if needed)
  Future<String> getTempViewPath(PdfFileModel pdf) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = path.join(tempDir.path, '${pdf.id}_view.pdf');
    
    final bytes = await readPdfFromSandbox(pdf);
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes);
    
    return tempPath;
  }

  /// Delete PDF file from sandbox
  Future<void> deletePdfFromSandbox(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Save thumbnail for PDF
  Future<String?> saveThumbnail(String pdfId, Uint8List thumbnailBytes) async {
    try {
      final thumbDir = await getThumbnailStorageDirectory();
      final fileName = '$pdfId.png';
      final thumbPath = path.join(thumbDir.path, fileName);
      
      final thumbFile = File(thumbPath);
      await thumbFile.writeAsBytes(thumbnailBytes);
      
      return thumbPath;
    } catch (e) {
      print('Error saving thumbnail: $e');
      return null;
    }
  }

  /// Delete thumbnail
  Future<void> deleteThumbnail(String? thumbnailPath) async {
    if (thumbnailPath == null) return;
    
    final file = File(thumbnailPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    final tempDir = await getTemporaryDirectory();
    final files = tempDir.listSync();
    
    for (var file in files) {
      if (file is File && file.path.endsWith('_view.pdf')) {
        try {
          await file.delete();
        } catch (e) {
          print('Error deleting temp file: $e');
        }
      }
    }
  }

  /// Get file size
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  /// Export PDF to external storage
  Future<void> exportPdf(PdfFileModel pdf, String destinationPath) async {
    final bytes = await readPdfFromSandbox(pdf);
    final destFile = File(destinationPath);
    await destFile.writeAsBytes(bytes);
  }
}
