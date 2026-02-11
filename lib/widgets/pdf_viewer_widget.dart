import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../models/pdf_file_model.dart';
import '../services/pdf_sandbox_service.dart';
import '../services/database_service.dart';

class PdfViewerWidget extends StatefulWidget {
  final PdfFileModel pdf;

  const PdfViewerWidget({super.key, required this.pdf});

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  final _sandboxService = PdfSandboxService();
  final _databaseService = DatabaseService();
  String? _tempFilePath;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get temporary file path (decrypted if needed)
      final tempPath = await _sandboxService.getTempViewPath(widget.pdf);

      setState(() {
        _tempFilePath = tempPath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPdf,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_tempFilePath == null) {
      return const Center(
        child: Text('No PDF loaded'),
      );
    }

    final settings = _databaseService.getSettings();

    // Use pdfrx viewer
    return _buildPdfrxViewer(settings.useDarkPdfBackground);
  }

  Widget _buildPdfrxViewer(bool useDarkBackground) {
    final viewer = PdfViewer.file(
      _tempFilePath!,
      params: PdfViewerParams(
        loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
          return Center(
            child: CircularProgressIndicator(
              value: totalBytes != null ? bytesDownloaded / totalBytes : null,
              backgroundColor: Colors.grey,
            ),
          );
        },
        errorBannerBuilder: (context, error, stackTrace, documentRef) {
          return Center(
            child: Text('Error: $error'),
          );
        },
      ),
    );

    if (useDarkBackground) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.difference,
        ),
        child: viewer,
      );
    }

    return viewer;
  }

  @override
  void dispose() {
    // Cleanup will be handled by sandbox service
    super.dispose();
  }
}
