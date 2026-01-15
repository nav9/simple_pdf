import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'services/file_saver.dart';
import 'services/pdf_processor.dart';

class PdfSplitMergeScreen extends StatefulWidget {
  final String pdfPath;
  const PdfSplitMergeScreen(this.pdfPath, {super.key});

  @override
  State<PdfSplitMergeScreen> createState() => _PdfSplitMergeScreenState();
}

class _PdfSplitMergeScreenState extends State<PdfSplitMergeScreen> {
  late List<bool> selected;

  @override
  void initState() {
    super.initState();
    final pageCount =
        PdfProcessorService.getPageCount(File(widget.pdfPath));
    selected = List.generate(pageCount, (_) => false);
  }

  Future<void> splitAndMerge() async {
    final selectedIndexes = selected
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedIndexes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one page')),
      );
      return;
    }

    final bytes = PdfProcessorService.mergeSelectedPages(
      sourcePdf: File(widget.pdfPath),
      pageIndexes: selectedIndexes,
    );



final savedPath = await FileSaverService.saveFile(
  bytes: bytes,
  fileName: 'merged.pdf',
);


    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Saved'),
        content: Text('File saved at:\n$savedPath'),
        actions: [
          TextButton(
            onPressed: () => OpenFilex.open(savedPath),
            child: const Text('Open'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split & Merge'),
      actions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: splitAndMerge,
          tooltip: 'Save merged PDF',
        ),
      ],
    ),      
      body: ListView.builder(
        itemCount: selected.length,
        itemBuilder: (_, i) => CheckboxListTile(
          title: Text('Page ${i + 1}'),
          value: selected[i],
          onChanged: (v) => setState(() => selected[i] = v!),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: splitAndMerge,
      //   child: const Icon(Icons.save),
      // ),
    );
  }
}
