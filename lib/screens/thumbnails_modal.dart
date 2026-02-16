
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../models/pdf_file_model.dart';
import '../services/pdf_sandbox_service.dart';

class ThumbnailsModal extends StatefulWidget {
  final PdfFileModel pdf;

  const ThumbnailsModal({super.key, required this.pdf});

  @override
  State<ThumbnailsModal> createState() => _ThumbnailsModalState();
}

class _ThumbnailsModalState extends State<ThumbnailsModal> {
  final _sandboxService = PdfSandboxService();
  PdfDocument? _document;
  final Set<int> _selectedPages = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final path = await _sandboxService.getTempViewPath(widget.pdf);
      final document = await PdfDocument.openFile(path);
      setState(() {
        _document = document;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _document?.dispose();
    super.dispose();
  }

  void _togglePage(int pageNumber) {
    setState(() {
      if (_selectedPages.contains(pageNumber)) {
        _selectedPages.remove(pageNumber);
      } else {
        _selectedPages.add(pageNumber);
      }
    });
  }

  void _selectAll() {
    if (_document == null) return;
    setState(() {
      for (int i = 1; i <= _document!.pages.length; i++) {
        _selectedPages.add(i);
      }
    });
  }

  void _selectNone() {
    setState(() {
      _selectedPages.clear();
    });
  }

  Future<void> _mergeAndSave() async {
    if (_selectedPages.isEmpty) return;

    // Note: pdfrx does not support creating/merging PDFs. 
    // We return selected pages to caller.
    Navigator.pop(context, _selectedPages.toList()..sort());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _document == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _selectAll,
            tooltip: 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.deselect),
            onPressed: _selectNone,
            tooltip: 'Select None',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _selectedPages.isNotEmpty ? _mergeAndSave : null,
            tooltip: 'Merge & Save',
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _document!.pages.length,
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          final isSelected = _selectedPages.contains(pageNumber);
          return GestureDetector(
            onTap: () => _togglePage(pageNumber),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return IgnorePointer(
                        child: PdfPageView(
                          document: _document!,
                          pageNumber: pageNumber,
                          alignment: Alignment.center,
                        ),
                      );
                    }
                  ),
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      color: Colors.black54,
                      child: Text(
                        '$pageNumber',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
