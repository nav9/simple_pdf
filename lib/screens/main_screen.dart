import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/pdf_file_model.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'trash_screen.dart';
import 'about_screen.dart';
import 'load_pdf_modal.dart';
import '../widgets/pdf_viewer_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final _databaseService = DatabaseService();
  TabController? _tabController;
  List<PdfFileModel> _openPdfs = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _openPdf(PdfFileModel pdf) {
    setState(() {
      if (!_openPdfs.any((p) => p.id == pdf.id)) {
        _openPdfs.add(pdf);
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
    if (_openPdfs.isEmpty) return;
    
    final currentIndex = _tabController?.index ?? 0;
    final pdf = _openPdfs[currentIndex];

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
      _closePdf(currentIndex);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pdf.name} moved to trash')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Simple PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load PDF',
            onPressed: _showLoadPdfModal,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'move_to_trash':
                  _movePdfToTrash();
                  break;
                case 'save_to_storage':
                  // TODO: Implement save to storage
                  break;
                case 'dark_background':
                  // TODO: Implement dark background toggle
                  break;
                case 'search':
                  // TODO: Implement search
                  break;
                case 'extract':
                  // TODO: Implement extract
                  break;
                case 'bookmark':
                  // TODO: Implement bookmark
                  break;
                case 'jump_to_page':
                  // TODO: Implement jump to page
                  break;
                case 'fullscreen':
                  // TODO: Implement fullscreen
                  break;
                case 'select_pages':
                  // TODO: Implement page selection
                  break;
                case 'rename':
                  // TODO: Implement rename
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'move_to_trash',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Move to Trash'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'save_to_storage',
                child: ListTile(
                  leading: Icon(Icons.save),
                  title: Text('Save to Storage'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'dark_background',
                child: ListTile(
                  leading: Icon(Icons.brightness_4),
                  title: Text('Toggle Dark Background'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'search',
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: Text('Search'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'extract',
                child: ListTile(
                  leading: Icon(Icons.content_copy),
                  title: Text('Extract Content'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'bookmark',
                child: ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text('Bookmarks'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'jump_to_page',
                child: ListTile(
                  leading: Icon(Icons.pageview),
                  title: Text('Jump to Page'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'fullscreen',
                child: ListTile(
                  leading: Icon(Icons.fullscreen),
                  title: Text('Fullscreen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'select_pages',
                child: ListTile(
                  leading: Icon(Icons.select_all),
                  title: Text('Select Pages'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'rename',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Rename'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: _openPdfs.isNotEmpty
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _openPdfs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pdf = entry.value;
                  return Tab(
                    child: Row(
                      children: [
                        Text(pdf.name),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _closePdf(index),
                          child: const Icon(Icons.close, size: 16),
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
                  Icon(
                    Icons.picture_as_pdf,
                    size: 48,
                    color: Colors.white,
                  ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Trash'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrashScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _openPdfs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No PDF opened',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the folder icon to load a PDF',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: _openPdfs.map((pdf) {
                return PdfViewerWidget(pdf: pdf);
              }).toList(),
            ),
    );
  }
}
