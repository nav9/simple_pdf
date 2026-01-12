import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../services/manipulation_service.dart';
import '../services/extraction_service.dart';
import '../services/conversion_service.dart';
import '../services/storage_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final String? filePath;
  final String? fileUrl;

  const PdfViewerScreen({
    super.key,
    this.filePath,
    this.fileUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isFullscreen = false;
  bool _invertColors = false;
  PdfViewerController? _controller;
  
  final ManipulationService _manipulationService = ManipulationService();
  final ExtractionService _extractionService = ExtractionService();
  final ConversionService _conversionService = ConversionService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
  }

  @override
  void dispose() {
    // PdfViewerController doesn't need manual disposal in pdfrx
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _toggleColorInversion() {
    setState(() {
      _invertColors = !_invertColors;
    });
  }

  Future<void> _splitPdf() async {
    if (widget.filePath == null) {
      _showMessage('Split is only available for local files');
      return;
    }

    try {
      // Get page count
      final pageCount = await _manipulationService.getPageCount(widget.filePath!);
      
      if (pageCount == 0) {
        _showMessage('Could not read PDF pages');
        return;
      }

      // Show page selection dialog (simplified - you can create a more advanced UI)
      final selectedPages = await showDialog<List<int>>(
        context: context,
        builder: (context) => _PageSelectionDialog(pageCount: pageCount),
      );

      if (selectedPages == null || selectedPages.isEmpty) return;

      // Pick output directory
      final outputDir = await _storageService.pickDirectory();
      if (outputDir == null) return;

      // Show loading
      _showLoading('Splitting PDF...');

      // Split PDF
      final fileName = widget.filePath!.split('/').last.replaceAll('.pdf', '_split.pdf');
      final outputPath = '$outputDir/$fileName';
      
      await _manipulationService.splitPdf(
        sourcePath: widget.filePath!,
        pageNumbers: selectedPages,
        outputPath: outputPath,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        _showMessage('PDF split successfully!\nSaved to: $outputPath');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showMessage('Error splitting PDF: ${e.toString()}');
      }
    }
  }

  Future<void> _extractText() async {
    if (widget.filePath == null) {
      _showMessage('Text extraction is only available for local files');
      return;
    }

    try {
      // Pick output directory
      final outputDir = await _storageService.pickDirectory();
      if (outputDir == null) return;

      _showLoading('Extracting text...');

      final fileName = widget.filePath!.split('/').last.replaceAll('.pdf', '.txt');
      final outputPath = '$outputDir/$fileName';

      await _extractionService.extractTextToFile(
        pdfPath: widget.filePath!,
        outputPath: outputPath,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        _showMessage('Text extracted successfully!\nSaved to: $outputPath');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showMessage('Error extracting text: ${e.toString()}');
      }
    }
  }

  Future<void> _extractImages() async {
    if (widget.filePath == null) {
      _showMessage('Image extraction is only available for local files');
      return;
    }

    try {
      final outputDir = await _storageService.pickDirectory();
      if (outputDir == null) return;

      _showLoading('Extracting images...');

      final images = await _extractionService.extractImages(
        filePath: widget.filePath!,
        outputDirectory: outputDir,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        if (images.isEmpty) {
          _showMessage('No images found in PDF');
        } else {
          _showMessage('Extracted ${images.length} image(s)\nSaved to: $outputDir');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showMessage('Error extracting images: ${e.toString()}');
      }
    }
  }

  Future<void> _convertPdf() async {
    if (widget.filePath == null) {
      _showMessage('Conversion is only available for local files');
      return;
    }

    final format = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Convert to'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'txt'),
            child: const Text('TXT (Text File)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'doc'),
            child: const Text('DOC (Coming Soon)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'docx'),
            child: const Text('DOCX (Coming Soon)'),
          ),
        ],
      ),
    );

    if (format == null) return;

    if (format != 'txt') {
      _showMessage('Conversion to $format requires cloud API integration (coming soon)');
      return;
    }

    try {
      final outputDir = await _storageService.pickDirectory();
      if (outputDir == null) return;

      _showLoading('Converting to TXT...');

      final fileName = widget.filePath!.split('/').last.replaceAll('.pdf', '.txt');
      final outputPath = '$outputDir/$fileName';

      await _conversionService.pdfToTxt(
        pdfPath: widget.filePath!,
        outputPath: outputPath,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        _showMessage('Converted successfully!\nSaved to: $outputPath');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showMessage('Error converting: ${e.toString()}');
      }
    }
  }

  void _showLoading(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: Text(widget.filePath?.split('/').last ?? 'PDF Viewer'),
              actions: [
                IconButton(
                  icon: Icon(_invertColors ? Icons.invert_colors_off : Icons.invert_colors),
                  onPressed: _toggleColorInversion,
                  tooltip: 'Invert Colors',
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullscreen,
                  tooltip: 'Fullscreen',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'split':
                        _splitPdf();
                        break;
                      case 'extract_text':
                        _extractText();
                        break;
                      case 'extract_images':
                        _extractImages();
                        break;
                      case 'convert':
                        _convertPdf();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'split', child: Text('Split PDF')),
                    const PopupMenuItem(value: 'extract_text', child: Text('Extract Text')),
                    const PopupMenuItem(value: 'extract_images', child: Text('Extract Images')),
                    const PopupMenuItem(value: 'convert', child: Text('Convert')),
                  ],
                ),
              ],
            ),
      body: widget.filePath != null
          ? PdfViewer.file(
              widget.filePath!,
              controller: _controller,
              params: PdfViewerParams(
                enableTextSelection: true,
                backgroundColor: _invertColors ? Colors.black : Colors.white,
              ),
            )
          : widget.fileUrl != null
              ? PdfViewer.uri(
                  Uri.parse(widget.fileUrl!),
                  controller: _controller,
                  params: PdfViewerParams(
                    enableTextSelection: true,
                    backgroundColor: _invertColors ? Colors.black : Colors.white,
                  ),
                )
              : const Center(
                  child: Text('No PDF file specified'),
                ),
      floatingActionButton: _isFullscreen
          ? FloatingActionButton(
              onPressed: _toggleFullscreen,
              child: const Icon(Icons.fullscreen_exit),
            )
          : null,
    );
  }
}

// Simple page selection dialog
class _PageSelectionDialog extends StatefulWidget {
  final int pageCount;

  const _PageSelectionDialog({required this.pageCount});

  @override
  State<_PageSelectionDialog> createState() => _PageSelectionDialogState();
}

class _PageSelectionDialogState extends State<_PageSelectionDialog> {
  final Set<int> _selectedPages = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Pages'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: widget.pageCount,
          itemBuilder: (context, index) {
            final pageNumber = index + 1;
            return CheckboxListTile(
              title: Text('Page $pageNumber'),
              value: _selectedPages.contains(pageNumber),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedPages.add(pageNumber);
                  } else {
                    _selectedPages.remove(pageNumber);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedPages.isEmpty
              ? null
              : () => Navigator.pop(context, _selectedPages.toList()..sort()),
          child: Text('Split (${_selectedPages.length} pages)'),
        ),
      ],
    );
  }
}
