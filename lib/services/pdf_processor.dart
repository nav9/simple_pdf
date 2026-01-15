import 'dart:io';
import 'dart:ui'; // ✅ REQUIRED for Offset
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfProcessorService {
  static PdfDocument _load(File file) {
    return PdfDocument(inputBytes: file.readAsBytesSync());
  }

  static int getPageCount(File pdfFile) {
    final doc = _load(pdfFile);
    final count = doc.pages.count;
    doc.dispose();
    return count;
  }

  /// ✅ RELEASE-SAFE page merge
  static List<int> mergeSelectedPages({
    required File sourcePdf,
    required List<int> pageIndexes,
  }) {
    final sourceDoc = _load(sourcePdf);
    final newDoc = PdfDocument();

    for (final index in pageIndexes) {
      final page = sourceDoc.pages[index];
      newDoc.pages.add().graphics.drawPdfTemplate(
        page.createTemplate(),
        const Offset(0, 0),
      );
    }

    final bytes = newDoc.saveSync();
    newDoc.dispose();
    sourceDoc.dispose();

    return bytes;
  }

  static String extractText(File pdfFile) {
    final doc = _load(pdfFile);
    final extractor = PdfTextExtractor(doc);
    final text = extractor.extractText();
    doc.dispose();
    return text;
  }

  static bool isTextExtractable(File pdfFile) {
    return extractText(pdfFile).trim().isNotEmpty;
  }
}


// import 'dart:ui';
// import 'dart:io';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

// class PdfProcessorService {
//   static PdfDocument _load(File file) {
//     return PdfDocument(inputBytes: file.readAsBytesSync());
//   }

//   static int getPageCount(File pdfFile) {
//     final doc = _load(pdfFile);
//     final count = doc.pages.count;
//     doc.dispose();
//     return count;
//   }

//   /// ✅ RELEASE-SAFE merge
//   static List<int> mergeSelectedPages({
//     required File sourcePdf,
//     required List<int> pageIndexes,
//   }) {
//     final sourceDoc = _load(sourcePdf);
//     final newDoc = PdfDocument();

//     for (final index in pageIndexes) {
//       final page = sourceDoc.pages[index];
//       newDoc.pages.add().graphics.drawPdfTemplate(
//         page.createTemplate(),
//         const Offset(0, 0),
//       );
//     }

//     final bytes = newDoc.saveSync();
//     newDoc.dispose();
//     sourceDoc.dispose();

//     return bytes;
//   }

//   static String extractText(File pdfFile) {
//     final doc = _load(pdfFile);
//     final extractor = PdfTextExtractor(doc);
//     final text = extractor.extractText();
//     doc.dispose();
//     return text;
//   }

//   static bool isTextExtractable(File pdfFile) {
//     return extractText(pdfFile).trim().isNotEmpty;
//   }
// }
