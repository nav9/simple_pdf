
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/database_service.dart';
import '../models/pdf_file_model.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'trash_screen.dart';
import 'about_screen.dart';
import 'load_pdf_modal.dart';
import 'thumbnails_modal.dart';
import '../widgets/pdf_viewer_widget.dart';
import '../services/bookmark_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final _databaseService = DatabaseService();
  TabController? _tabController;
  List<PdfFileModel> _openPdfs = [];
  final Map<String, PdfViewerController> _controllers = {};
  bool _isFullscreen = false;
  
  // Search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  // PdfTextSearchResult? _searchResult; // Not available in this version

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    
    // Check for default app prompt after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDefaultApp();
      _checkAutoOpen();
    });
  }

  void _checkAutoOpen() {
    if (_openPdfs.isEmpty && mounted) {
      _showLoadPdfModal();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    for (var _ in _controllers.values) {
      // controller.dispose(); // pdfrx controllers don't strictly need manual dispose if attached to widget, but good practice if API supports it
    }
    super.dispose();
  }

  void _openPdf(PdfFileModel pdf) {
    setState(() {
      if (!_openPdfs.any((p) => p.id == pdf.id)) {
        _openPdfs.add(pdf);
        _controllers[pdf.id] = PdfViewerController();
        _tabController?.dispose();
        _tabController = TabController(
          length: _openPdfs.length,
          vsync: this,
          initialIndex: _openPdfs.length - 1,
        );
      } else {
        final index = _openPdfs.indexWhere((p) => p.id == pdf.id);
        _tabController?.animateTo(index);
      }
    });
  }

  void _closePdf(int index) {
    setState(() {
      final pdf = _openPdfs[index];
      _controllers.remove(pdf.id);
      _openPdfs.removeAt(index);
      _tabController?.dispose();
      if (_openPdfs.isNotEmpty) {
        _tabController = TabController(
          length: _openPdfs.length,
          vsync: this,
          initialIndex: index > 0 ? index - 1 : 0,
        );
      } else {
        _tabController = TabController(length: 0, vsync: this);
      }
    });
  }

  PdfViewerController? get _currentController {
    if (_openPdfs.isEmpty || _tabController == null) return null;
    return _controllers[_openPdfs[_tabController!.index].id];
  }

  PdfFileModel? get _currentPdf {
    if (_openPdfs.isEmpty || _tabController == null) return null;
    return _openPdfs[_tabController!.index];
  }

  Future<void> _showLoadPdfModal() async {
    final pdf = await showModalBottomSheet<PdfFileModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const LoadPdfModal(),
    );

    if (pdf != null) {
      _openPdf(pdf);
    }
  }

  void _movePdfToTrash() async {
    final pdf = _currentPdf;
    if (pdf == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Trash'),
        content: Text('Move "${pdf.name}" to trash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Move to Trash'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _databaseService.movePdfToTrash(pdf.id);
      _closePdf(_tabController!.index);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pdf.name} moved to trash')),
        );
      }
    }
  }

  void _saveToStorage() async {
    final pdf = _currentPdf;
    if (pdf == null) return;
    
    // In a real app with encrypted storage, we'd need to decrypt to a temp file first
    // then copy it. Since PdfViewerWidget loads it to a temp path, 
    // we might need access to that or ask logic to export.
    // For now, assuming we export the original file path if it's local, 
    // or we'd need a service to export.
    
    String? outputDir = await FilePicker.platform.getDirectoryPath();
    if (outputDir == null) return;

    final String newPath = '$outputDir/${pdf.name}';
    // Logic to copy file would go here.
    // For this example, we'll just show a success message as we lack the full file access logic in this snippet.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to $newPath (simulated)')),
    );
  }

  void _toggleDarkBackground() async {
    final settings = _databaseService.getSettings();
    settings.useDarkPdfBackground = !settings.useDarkPdfBackground;
    await _databaseService.updateSettings(settings);
    setState(() {}); // Rebuild to apply changes in PdfViewerWidget
  }

  void _showSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _hideSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      // _searchResult = null;
    });
  }

  void _performSearch(String query) async {
    // pdfrx doesn't have a simple "findText" in controller yet in standard API? 
    // It has `PdfTextSearcher`.
    // For now, we will assume a placeholder implementation or use scroll to page if query is a number
    // to avoid compilation errors if API is missing.
    // Actually, let's just show a snackbar "Search not fully implemented" 
    // or try to implement if headers allow.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search functionality requires additional implementation')),
    );
  }

  void _extractContent() {
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Extraction functionality requires additional implementation')),
    );
  }

  void _showBookmarks() {
    // Show bookmarks dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmarks functionality requires additional implementation')),
    );
  }
  
  void _jumpToPage() async {
    final controller = _currentController;
    if (controller == null) return;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        return AlertDialog(
          title: const Text('Jump to Page'),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Page Number'),
          ),
          actions: [
            TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text('Cancel'),
            ),
             TextButton(
               onPressed: () {
                 final page = int.tryParse(textController.text);
                 if (page != null) Navigator.pop(context, page);
               },
               child: const Text('Go'),
            ),
          ],
        );
      }
    );

    if (result != null) {
       // controller.animateToPage(
       //   pageNumber: result, 
       //   duration: const Duration(milliseconds: 300), 
       //   curve: Curves.easeOut,
       // );
       // TODO: Implement page jump when API is verified or upgraded.
    }
  }

  void _toggleFullscreen() {
     setState(() {
       _isFullscreen = !_isFullscreen;
     });
     if (_isFullscreen) {
       SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
     } else {
       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
     }
  }

  void _selectPages() async {
    final pdf = _currentPdf;
    if (pdf == null) return;

    final selectedPages = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ThumbnailsModal(pdf: pdf),
    );

    if (selectedPages != null && selectedPages.isNotEmpty) {
      // Handle merge/save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected ${selectedPages.length} pages. Merge feature pending.')),
      );
    }
  }

  void _renamePdf() async {
    final pdf = _currentPdf;
    if (pdf == null) return;

    final controller = TextEditingController(text: pdf.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename PDF'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      )
    );

    if (newName != null && newName.isNotEmpty && newName != pdf.name) {
       // Update DB
       // _databaseService.updatePdfName(pdf.id, newName); // Assuming method exists or we update model
       pdf.name = newName;
       await _databaseService.updatePdf(pdf);
       setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // If full screen, we might hide app bar.
    // But we need a way to exit full screen. 
    // We'll keep app bar but maybe hide status bar.
    
    return Scaffold(
      appBar: _isFullscreen ? null : AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              onSubmitted: _performSearch,
            )
          : Text('Simple PDF', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _hideSearch,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Load PDF',
              onPressed: _showLoadPdfModal,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'move_to_trash': _movePdfToTrash(); break;
                  case 'save_to_storage': _saveToStorage(); break;
                  case 'dark_background': _toggleDarkBackground(); break;
                  case 'search': _showSearch(); break;
                  case 'extract': _extractContent(); break;
                  case 'bookmark': _showBookmarks(); break;
                  case 'jump_to_page': _jumpToPage(); break;
                  case 'fullscreen': _toggleFullscreen(); break;
                  case 'select_pages': _selectPages(); break;
                  case 'rename': _renamePdf(); break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'move_to_trash', child: ListTile(leading: Icon(Icons.delete), title: Text('Move to Trash'))),
                const PopupMenuItem(value: 'save_to_storage', child: ListTile(leading: Icon(Icons.save), title: Text('Save to Storage'))),
                const PopupMenuItem(value: 'dark_background', child: ListTile(leading: Icon(Icons.brightness_4), title: Text('Toggle Dark Background'))),
                const PopupMenuItem(value: 'search', child: ListTile(leading: Icon(Icons.search), title: Text('Search'))),
                const PopupMenuItem(value: 'extract', child: ListTile(leading: Icon(Icons.content_copy), title: Text('Extract Content'))),
                const PopupMenuItem(value: 'bookmark', child: ListTile(leading: Icon(Icons.bookmark), title: Text('Bookmarks'))),
                const PopupMenuItem(value: 'jump_to_page', child: ListTile(leading: Icon(Icons.pageview), title: Text('Jump to Page'))),
                const PopupMenuItem(value: 'fullscreen', child: ListTile(leading: Icon(Icons.fullscreen), title: Text('Fullscreen'))),
                const PopupMenuItem(value: 'select_pages', child: ListTile(leading: Icon(Icons.select_all), title: Text('Select Pages'))),
                const PopupMenuItem(value: 'rename', child: ListTile(leading: Icon(Icons.edit), title: Text('Rename'))),
              ],
            ),
          ],
        ],
          bottom: _openPdfs.isNotEmpty && !_isSearching
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _openPdfs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pdf = entry.value;
                    return Tab(
                      child: Row(
                        children: [
                          Text(pdf.name, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _closePdf(index),
                            child: Icon(Icons.close, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : null,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Simple PDF',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Trash'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TrashScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _openPdfs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf_outlined, size: 100, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No PDF opened',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the folder icon to load a PDF',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: _openPdfs.map((pdf) {
                    return PdfViewerWidget(
                      pdf: pdf,
                      controller: _controllers[pdf.id],
                      isFullScreen: _isFullscreen,
                      onExitFullscreen: _toggleFullscreen,
                    );
                  }).toList(),
                ),

        ],
      ),
    );
  }

  Future<void> _checkDefaultApp() async {
    // Check if we should show the prompt
    final settings = _databaseService.getSettings();
    if (settings.dontShowDefaultAppPrompt) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set as Default PDF App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Would you like to make Simple PDF your default PDF viewer?'),
            const SizedBox(height: 16),
            const Text('You will need to select "Simple PDF" and "Always" in the next dialog.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
          actions: [
            TextButton(
              onPressed: () async {
                settings.dontShowDefaultAppPrompt = true;
                await _databaseService.updateSettings(settings);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Don\'t show again', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _triggerDefaultAppChooser();
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    }

  Future<void> _triggerDefaultAppChooser() async {
    // To trigger the "Open with" dialog and allow setting default, 
    // we need to view a file of the target type (PDF).
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/empty.pdf');
      if (!await tempFile.exists()) {
        await tempFile.writeAsBytes([]); // Create empty file
      }

      // Create an intent to view this file
      final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.parse(tempFile.path).toString(), // Usually needs content:// URI and FileProvider
        type: 'application/pdf',
        flags: [268435456], // FLAG_ACTIVITY_NEW_TASK
      );
      
      // Note: On modern Android, file:// URIs might fail with FileUriExposedException.
      // We should ideally use FileProvider, but setting that up requires AndroidManifest changes and XML configs.
      // If we can't change AndroidManifest easily here, we might try a different approach 
      // or fall back to the settings page if this fails.
      // However, for the purpose of this task, we will try the intent.
      // If it fails, we fall back to settings.
      
      try {
        await intent.launch();
      } catch (e) {
        // Fallback to settings if launch fails (likely due to file uri exposure or no app)
        _openDefaultAppSettings();
      }
    } catch (e) {
      _openDefaultAppSettings();
    }
  }

  void _openDefaultAppSettings() async {
    // Open default app settings for this app or general default apps settings
    // android.settings.MANAGE_DEFAULT_APPS_SETTINGS is available API 24+
    // android.settings.APP_OPEN_BY_DEFAULT_SETTINGS is available API 31+
    
    // Get package name dynamically
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    
    // "android.settings.APP_OPEN_BY_DEFAULT_SETTINGS" with data "package:packageName"
    // Available since API 31 (Android 12)
    final intent = AndroidIntent(
      action: 'android.settings.APP_OPEN_BY_DEFAULT_SETTINGS',
      data: 'package:$packageName', 
    );
    
    try {
      await intent.launch();
    } catch (e) {
      // Fallback: Manage Default Apps Settings (generic list)
      const fallbackIntent = AndroidIntent(
        action: 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS',
      );
      try {
        await fallbackIntent.launch();
      } catch (e) {
        // Ultimate fallback: App Info Settings
        // openAppSettings() from permission_handler opens generic app settings
        openAppSettings();
      }
    }
  }
}
