import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/constants.dart';

class ManipulationService {
  /// Split PDF by extracting selected pages
  Future<String> splitPdf({
    required String sourcePath,
    required List<int> pageNumbers,
    required String outputPath,
  }) async {
    try {
      // Load source PDF
      final sourceFile = File(sourcePath);
      final sourceBytes = await sourceFile.readAsBytes();
      final sourceDocument = PdfDocument(inputBytes: sourceBytes);
      
      // Create new PDF document
      final newDocument = PdfDocument();
      
      // Import selected pages
      for (final pageNumber in pageNumbers) {
        if (pageNumber > 0 && pageNumber <= sourceDocument.pages.count) {
          // Add a new page and draw the template from source page
          final page = newDocument.pages.add();
          final template = sourceDocument.pages[pageNumber - 1].createTemplate();
          page.graphics.drawPdfTemplate(template, const Offset(0, 0));
        }
      }
      
      // Save new PDF
      final bytes = await newDocument.save();
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      // Dispose documents
      newDocument.dispose();
      sourceDocument.dispose();
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to split PDF: ${e.toString()}');
    }
  }
  
  /// Merge multiple PDFs into one
  Future<String> mergePdfs({
    required List<String> sourcePaths,
    required String outputPath,
    Map<String, List<int>>? selectedPages, // Optional: specific pages from each file
  }) async {
    try {
      final mergedDocument = PdfDocument();
      
      for (int i = 0; i < sourcePaths.length; i++) {
        final sourcePath = sourcePaths[i];
        final sourceFile = File(sourcePath);
        final sourceBytes = await sourceFile.readAsBytes();
        final sourceDocument = PdfDocument(inputBytes: sourceBytes);
        
        // Get pages to import
        List<int> pagesToImport;
        if (selectedPages != null && selectedPages.containsKey(sourcePath)) {
          pagesToImport = selectedPages[sourcePath]!;
        } else {
          // Import all pages
          pagesToImport = List.generate(
            sourceDocument.pages.count,
            (index) => index + 1,
          );
        }
        
        // Import selected pages
        for (final pageNumber in pagesToImport) {
          if (pageNumber > 0 && pageNumber <= sourceDocument.pages.count) {
            final page = mergedDocument.pages.add();
            final template = sourceDocument.pages[pageNumber - 1].createTemplate();
            page.graphics.drawPdfTemplate(template, const Offset(0, 0));
          }
        }
        
        sourceDocument.dispose();
      }
      
      // Save merged PDF
      final bytes = await mergedDocument.save();
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      mergedDocument.dispose();
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to merge PDFs: ${e.toString()}');
    }
  }
  
  /// Get page count of a PDF
  Future<int> getPageCount(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final count = document.pages.count;
      document.dispose();
      return count;
    } catch (e) {
      return 0;
    }
  }
  
  /// Get PDF information
  Future<Map<String, dynamic>> getPdfInfo(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      
      final info = {
        'pageCount': document.pages.count,
        'fileSize': bytes.length,
        'title': document.documentInformation.title,
        'author': document.documentInformation.author,
        'subject': document.documentInformation.subject,
        'keywords': document.documentInformation.keywords,
        'creator': document.documentInformation.creator,
        'producer': document.documentInformation.producer,
        'creationDate': document.documentInformation.creationDate,
        'modificationDate': document.documentInformation.modificationDate,
      };
      
      document.dispose();
      return info;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  /// Rotate pages in a PDF
  Future<String> rotatePdf({
    required String sourcePath,
    required String outputPath,
    required int rotation, // 90, 180, or 270 degrees
    List<int>? pageNumbers, // null means all pages
  }) async {
    try {
      final sourceFile = File(sourcePath);
      final sourceBytes = await sourceFile.readAsBytes();
      final document = PdfDocument(inputBytes: sourceBytes);
      
      final pagesToRotate = pageNumbers ?? 
        List.generate(document.pages.count, (index) => index + 1);
      
      for (final pageNumber in pagesToRotate) {
        if (pageNumber > 0 && pageNumber <= document.pages.count) {
          final page = document.pages[pageNumber - 1];
          
          // Set rotation
          switch (rotation) {
            case 90:
              page.rotation = PdfPageRotateAngle.rotateAngle90;
              break;
            case 180:
              page.rotation = PdfPageRotateAngle.rotateAngle180;
              break;
            case 270:
              page.rotation = PdfPageRotateAngle.rotateAngle270;
              break;
            default:
              page.rotation = PdfPageRotateAngle.rotateAngle0;
          }
        }
      }
      
      final bytes = await document.save();
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(bytes);
      
      document.dispose();
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to rotate PDF: ${e.toString()}');
    }
  }
}
