import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/constants.dart';

class ConversionService {
  /// Convert PDF to TXT
  Future<String> pdfToTxt({
    required String pdfPath,
    required String outputPath,
  }) async {
    try {
      final file = File(pdfPath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      
      final buffer = StringBuffer();
      final textExtractor = PdfTextExtractor(document);
      
      for (int i = 0; i < document.pages.count; i++) {
        final text = textExtractor.extractText(startPageIndex: i, endPageIndex: i);
        buffer.writeln(text);
        buffer.writeln();
      }
      
      document.dispose();
      
      // Save to file
      final outputFile = File(outputPath);
      await outputFile.writeAsString(buffer.toString());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to convert PDF to TXT: ${e.toString()}');
    }
  }
  
  /// Convert TXT to PDF
  Future<String> txtToPdf({
    required String txtPath,
    required String outputPath,
  }) async {
    try {
      final file = File(txtPath);
      final text = await file.readAsString();
      
      // Create PDF document using pdf package
      final pdf = pw.Document();
      
      // Split text into pages (simple approach: by lines)
      final lines = text.split('\n');
      const linesPerPage = 50; // Approximate
      
      for (int i = 0; i < lines.length; i += linesPerPage) {
        final pageLines = lines.skip(i).take(linesPerPage).join('\n');
        
        pdf.addPage(
          pw.Page(
            build: (context) => pw.Text(
              pageLines,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
        );
      }
      
      // Save PDF
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await pdf.save());
      
      return outputPath;
    } catch (e) {
      throw Exception('Failed to convert TXT to PDF: ${e.toString()}');
    }
  }
  
  /// Convert PDF to DOC/DOCX (placeholder - requires cloud API)
  Future<String> pdfToDoc({
    required String pdfPath,
    required String outputPath,
    String format = 'docx',
  }) async {
    throw UnimplementedError(
      'PDF to DOC/DOCX conversion requires cloud API integration. '
      'Consider using services like CloudConvert or Aspose Cloud API.'
    );
  }
  
  /// Convert DOC/DOCX to PDF (placeholder - requires cloud API)
  Future<String> docToPdf({
    required String docPath,
    required String outputPath,
  }) async {
    throw UnimplementedError(
      'DOC/DOCX to PDF conversion requires cloud API integration. '
      'Consider using services like CloudConvert or Aspose Cloud API.'
    );
  }
  
  /// Convert PDF to PPT/PPTX (placeholder - requires cloud API)
  Future<String> pdfToPpt({
    required String pdfPath,
    required String outputPath,
  }) async {
    throw UnimplementedError(
      'PDF to PPT/PPTX conversion requires cloud API integration. '
      'Consider using services like CloudConvert or Aspose Cloud API.'
    );
  }
  
  /// Convert PPT/PPTX to PDF (placeholder - requires cloud API)
  Future<String> pptToPdf({
    required String pptPath,
    required String outputPath,
  }) async {
    throw UnimplementedError(
      'PPT/PPTX to PDF conversion requires cloud API integration. '
      'Consider using services like CloudConvert or Aspose Cloud API.'
    );
  }
  
  /// Get supported conversion formats
  Map<String, List<String>> getSupportedConversions() {
    return {
      'pdf': ['txt'], // PDF can be converted to TXT
      'txt': ['pdf'], // TXT can be converted to PDF
      'doc': [], // Requires cloud API
      'docx': [], // Requires cloud API
      'ppt': [], // Requires cloud API
      'pptx': [], // Requires cloud API
      'xls': [], // Requires cloud API
      'xlsx': [], // Requires cloud API
    };
  }
  
  /// Check if conversion is supported
  bool isConversionSupported(String fromFormat, String toFormat) {
    final supported = getSupportedConversions();
    return supported[fromFormat]?.contains(toFormat) ?? false;
  }
  
  /// Get conversion status message
  String getConversionMessage(String fromFormat, String toFormat) {
    if (isConversionSupported(fromFormat, toFormat)) {
      return 'Conversion from $fromFormat to $toFormat is supported';
    } else {
      return 'Conversion from $fromFormat to $toFormat requires cloud API integration (coming soon)';
    }
  }
}
