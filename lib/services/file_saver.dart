import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class FileSaverService {
  static Future<String> saveFile({
    required List<int> bytes,
    required String fileName,
  }) async {
    Directory dir;

    try {
      dir = await getApplicationDocumentsDirectory();
    } catch (_) {
      dir = Directory.systemTemp;
    }

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<void> openPath(String path) async {
    await OpenFilex.open(path);
  }
}


// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';

// class FileSaverService {
//   /// Save bytes to user-selected directory, fallback to internal storage
//   static Future<String> saveFile({
//     required List<int> bytes,
//     required String fileName,
//   }) async {
//     String? savedPath;

//     try {
//       final externalDir = await getExternalStorageDirectory();
//       if (externalDir != null) {
//         final file = File('${externalDir.path}/$fileName');
//         await file.writeAsBytes(bytes);
//         savedPath = file.path;
//       }
//     } catch (_) {
//       // ignore and fallback
//     }

//     if (savedPath == null) {
//       final internalDir = await getApplicationDocumentsDirectory();
//       final file = File('${internalDir.path}/$fileName');
//       await file.writeAsBytes(bytes);
//       savedPath = file.path;
//     }

//     return savedPath;
//   }

//   /// Save text file (TXT export)
//   static Future<String> saveTextFile({
//     required String content,
//     required String fileName,
//   }) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsString(content);
//     return file.path;
//   }

//   /// Open file or folder
//   static Future<void> openPath(String path) async {
//     await OpenFilex.open(path);
//   }

//   /// Verify file existence
//   static bool fileExists(String path) {
//     return File(path).existsSync();
//   }
// }
