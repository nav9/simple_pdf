import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfLoaderService {
  /// Pick PDF from local filesystem
  static Future<File?> loadFromFileSystem() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    return File(result.files.single.path!);
  }

  /// Download PDF from URL and store temporarily
  static Future<File> loadFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Failed to download PDF");
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/downloaded.pdf');
    await file.writeAsBytes(response.bodyBytes);

    return file;
  }
}
