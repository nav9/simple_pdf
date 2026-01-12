import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/constants.dart';

class ExtractionService {
  /// Extract text from PDF
  Future<String> extractText({
    required String filePath,
    List<int>? pageNumbers, // null means all pages
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      
      final buffer = StringBuffer();
      final pagesToExtract = pageNumbers ?? 
        List.generate(document.pages.count, (index) => index + 1);
      
      for (final pageNumber in pagesToExtract) {
        if (pageNumber > 0 && pageNumber <= document.pages.count) {
          final page = document.pages[pageNumber - 1];
          
          // Extract text from page
          final textExtractor = PdfTextExtractor(document);
          final text = textExtractor.extractText(startPageIndex: pageNumber - 1, endPageIndex: pageNumber - 1);
          
          buffer.writeln('--- Page $pageNumber ---');
          buffer.writeln(text);
          buffer.writeln();
        }
      }
      
      document.dispose();
      
      return buffer.toString();
    } catch (e) {
      throw Exception('Failed to extract text: ${e.toString()}');
    }
  }
  
  /// Extract text and save to file
  Future<String> extractTextToFile({
    required String pdfPath,
    required String outputPath,
    List<int>? pageNumbers,
  }) async {
    final text = await extractText(filePath: pdfPath, pageNumbers: pageNumbers);
    
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(text.codeUnits);
    
    return outputPath;
  }
  
  /// Extract images from PDF
  Future<List<String>> extractImages({
    required String filePath,
    required String outputDirectory,
    List<int>? pageNumbers,
  }) async {
    // Currently syncfusion_flutter_pdf does not support direct image extraction
    throw UnimplementedError(
      'Image extraction is currently not supported by the underlying engine. '
      'Consider using an alternative package like pdfx if this feature is critical.'
    );
  }
  
  /// Get text statistics
  Future<Map<String, dynamic>> getTextStatistics(String filePath) async {
    try {
      final text = await extractText(filePath: filePath);
      
      final words = text.split(RegExp(r'\s+'));
      final characters = text.replaceAll(RegExp(r'\s+'), '');
      final lines = text.split('\n');
      
      return {
        'totalCharacters': text.length,
        'charactersWithoutSpaces': characters.length,
        'words': words.where((w) => w.isNotEmpty).length,
        'lines': lines.length,
        'pages': lines.where((l) => l.contains('--- Page')).length,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  /// Search for text in PDF
  Future<List<Map<String, dynamic>>> searchText({
    required String filePath,
    required String searchQuery,
    bool caseSensitive = false,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      
      final results = <Map<String, dynamic>>[];
      final textExtractor = PdfTextExtractor(document);
      
      for (int i = 0; i < document.pages.count; i++) {
        final pageText = textExtractor.extractText(startPageIndex: i, endPageIndex: i);
        
        final searchText = caseSensitive ? pageText : pageText.toLowerCase();
        final query = caseSensitive ? searchQuery : searchQuery.toLowerCase();
        
        if (searchText.contains(query)) {
          // Find all occurrences
          int index = 0;
          while ((index = searchText.indexOf(query, index)) != -1) {
            // Get context (50 characters before and after)
            final start = (index - 50).clamp(0, searchText.length);
            final end = (index + query.length + 50).clamp(0, searchText.length);
            final context = pageText.substring(start, end);
            
            results.add({
              'page': i + 1,
              'position': index,
              'context': context,
            });
            
            index += query.length;
          }
        }
      }
      
      document.dispose();
      
      return results;
    } catch (e) {
      return [];
    }
  }
}
