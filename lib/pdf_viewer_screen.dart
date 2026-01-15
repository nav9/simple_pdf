import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'pdf_split_merge_screen.dart';

enum ScrollbarMode { left, right, none }

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? pdfPath;
  ScrollbarMode scrollbarMode = ScrollbarMode.right;

  Future<void> loadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() => pdfPath = result.files.single.path);
    }
  }

  Future<void> loadPdfFromUrl() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Load PDF from URL"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () async {
              final response = await http.get(Uri.parse(controller.text));
              final temp = File('${Directory.systemTemp.path}/temp.pdf');
              await temp.writeAsBytes(response.bodyBytes);
              setState(() => pdfPath = temp.path);
              Navigator.pop(context);
            },
            child: const Text("Load"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple PDF"),
        actions: [
          IconButton(icon: const Icon(Icons.folder_open), onPressed: loadPdf),
          IconButton(icon: const Icon(Icons.link), onPressed: loadPdfFromUrl),
          IconButton(
            icon: const Icon(Icons.call_split),
            onPressed: pdfPath == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfSplitMergeScreen(pdfPath!),
                      ),
                    ),
          ),
          PopupMenuButton<ScrollbarMode>(
            onSelected: (m) => setState(() => scrollbarMode = m),
            itemBuilder: (_) => const [
              PopupMenuItem(value: ScrollbarMode.left, child: Text("Scrollbar Left")),
              PopupMenuItem(value: ScrollbarMode.right, child: Text("Scrollbar Right")),
              PopupMenuItem(value: ScrollbarMode.none, child: Text("No Scrollbar")),
            ],
          ),
        ],
      ),
      body: pdfPath == null
          ? const Center(child: Text("Load a PDF"))
          : SfPdfViewer.file(
              File(pdfPath!),
              canShowScrollStatus: scrollbarMode != ScrollbarMode.none,
              scrollDirection: PdfScrollDirection.vertical,
            ),
    );
  }
}
