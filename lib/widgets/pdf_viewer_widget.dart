
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import '../models/pdf_file_model.dart';
import '../services/pdf_sandbox_service.dart';
import '../services/database_service.dart';

class PdfViewerWidget extends StatefulWidget {
  final PdfFileModel pdf;
  final PdfViewerController? controller;
  final VoidCallback? onExitFullscreen;
  final bool isFullScreen;

  const PdfViewerWidget({
    super.key,
    required this.pdf,
    this.controller,
    this.onExitFullscreen,
    this.isFullScreen = false,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  final _sandboxService = PdfSandboxService();
  final _databaseService = DatabaseService();
  String? _tempFilePath;
  bool _isLoading = true;
  String? _error;
  
  // Fullscreen & Controls State
  bool _showControls = false;
  Timer? _controlsTimer;
  int _currentPage = 1;
  int _totalPages = 0;
  
  // Zoom State
  Orientation? _currentOrientation;
  double _zoomPortrait = 1.0;
  double _zoomLandscape = 1.0;
  PdfViewerController? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? PdfViewerController();
    _loadPdf();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateOrientation();
  }

  void _updateOrientation() {
    final newOrientation = MediaQuery.of(context).orientation;
    if (_currentOrientation != newOrientation) {
      // Orientation changed
      // Save current zoom to old orientation
      _saveCurrentZoom();
      
      _currentOrientation = newOrientation;
      
      // Restore zoom for new orientation (after a short delay to let layout settle)
      Future.delayed(const Duration(milliseconds: 100), () {
        _restoreZoomForOrientation();
      });
    }
  }

  void _saveCurrentZoom() {
    if (_internalController?.isReady != true) return;
    
    // Zoom persistence disabled until API is verified
    // final zoom = _internalController?.zoomRatio ?? 1.0; 
    // if (_currentOrientation == Orientation.portrait) {
    //   _zoomPortrait = zoom;
    // } else {
    //   _zoomLandscape = zoom;
    // }
  }

  void _restoreZoomForOrientation() {
    if (_internalController?.isReady != true) return;
    
    // final targetZoom = _currentOrientation == Orientation.portrait ? _zoomPortrait : _zoomLandscape;
    
     try {
       // _internalController?.zoomUp(zoom: targetZoom);
     } catch (e) {
       // Ignore if method mismatch
     }
  }

  void _onDataLoaded(PdfDocument document) {
    setState(() {
      _totalPages = document.pages.length;
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // Unused
  // void _toggleControls() {
  //   setState(() {
  //     _showControls = !_showControls;
  //   });
  //   if (_showControls) {
  //     _resetHideTimer();
  //   } else {
  //     _controlsTimer?.cancel();
  //   }
  // }

  void _showControlsOverlay() {
    setState(() {
      _showControls = true;
    });
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get temporary file path (decrypted if needed)
      final tempPath = await _sandboxService.getTempViewPath(widget.pdf);

      if (mounted) {
        setState(() {
          _tempFilePath = tempPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading PDF: $e';
          _isLoading = false;
        });
      }
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
            const Icon(Icons.error, size: 64, color: Colors.red),
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
    return _buildPdfrxViewer(settings.useDarkPdfBackground, settings.scrollPhysics, settings.zoomPhysics);
  }

  Widget _buildPdfrxViewer(bool useDarkBackground, double scrollPhysics, double zoomPhysics) {
    return PopScope(
      canPop: !_isFullScreen(), 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_isFullScreen()) {
          _exitFullScreen();
        }
      },
      child: GestureDetector(
        onDoubleTap: _showControlsOverlay,
        onTap: () {
          // Optional: Toggle controls on single tap too? 
          // User asked: "If the user double taps on the screen the button should re-appear"
          // Usually single tap toggles, but requirement says double tap.
          // However, double tap might also zoom. 
          // Let's keep strict double tap for now, or maybe add single tap if needed.
        },
        child: Stack(
          children: [
            PdfViewer.file(
              _tempFilePath!,
              controller: _internalController,
              passwordProvider: _passwordProvider,
              params: PdfViewerParams(
                onViewerReady: (document, controller) => _onDataLoaded(document),
                onPageChanged: (page) {
                  if (page != null) _onPageChanged(page);
                },
                errorBannerBuilder: (context, error, stackTrace, documentRef) {
                  return Center(
                    child: Text('Error: $error'),
                  );
                },
              ),
            ),
            if (useDarkBackground)
               Positioned.fill(
                 child: IgnorePointer(
                   child: ColorFiltered(
                     colorFilter: const ColorFilter.mode(
                       Colors.white,
                       BlendMode.difference,
                     ),
                     child: Container(color: Colors.transparent), 
                   ),
                 ),
               ),
               
            // Controls Overlay
            if (_showControls && _isFullScreen()) ...[
              // Page Number Badge
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Page $_currentPage / $_totalPages',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              
              // Exit Fullscreen Button
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton.small(
                  backgroundColor: Colors.black54,
                  child: const Icon(Icons.fullscreen_exit, color: Colors.white),
                  onPressed: _exitFullScreen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isFullScreen() {
     return widget.isFullScreen; 
  }
  
  void _exitFullScreen() {
     // We need to notify parent (MainScreen) to exit fullscreen.
     // Since we don't have a callback, we can try `SystemChrome` directly 
     // BUT `MainScreen` has state `_isFullscreen`. 
     // Ideally `PdfViewerWidget` should have `onExitFullscreen` callback.
     
     // Since I cannot change `MainScreen` signature easily for `PdfViewerWidget` in this single tool call correctly
     // (it requires updating call sites), I will use a notification or assume MainScreen handles it?
     // No, MainScreen passes `controller`. 
     
     // Let's assume we can assume we are in fullscreen if standard fullscreen checks pass.
     // For "Exit", we can just restore SystemUI and let MainScreen update?
     // Or better: Use `Navigator.maybePop` if it was a route? No.
     
     // I will trigger a callback if I add it.
     // Let's add `onToggleFullscreen` or similar to params.
     // Wait, I can't add params easily without updating call site in `MainScreen` and `ThumbnailsModal` (if used there).
     // `ThumbnailsModal` likely doesn't use `PdfViewerWidget`.
     
     // Let's update `MainScreen` to pass the callback in next step.
     // For now, I'll put placeholder or implementation that assumes callback availability if I add it.
     
     widget.onExitFullscreen?.call();
  }

  Future<String?> _passwordProvider() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
            autofocus: true,
          ),
          actions: [
             TextButton(
               onPressed: () => Navigator.pop(context, null),
               child: const Text('Cancel'),
             ),
             TextButton(
               onPressed: () => Navigator.pop(context, controller.text),
               child: const Text('Unlock'),
             ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _saveCurrentZoom(); // Save on dispose? Maybe not needed if we only care about orientation switch during view.
    // _internalController.dispose(); // Do not dispose if passed from outside? 
    // Widget receives controller, so we don't own it presumably if passed.
    super.dispose();
  }
}
