import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Split PDF - Coming soon')),
                        );
                        break;
                      case 'extract_text':
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Extract Text - Coming soon')),
                        );
                        break;
                      case 'extract_images':
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Extract Images - Coming soon')),
                        );
                        break;
                      case 'convert':
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Convert - Coming soon')),
                        );
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
