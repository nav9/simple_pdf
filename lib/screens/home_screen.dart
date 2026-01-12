import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';
import '../utils/permissions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _openPdfFromDevice() async {
    // Request storage permission
    final hasPermission = await PermissionHelper.requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
      }
      return;
    }

    // Pick PDF file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: Constants.pdfExtensions,
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/pdf_viewer',
          arguments: {'filePath': filePath},
        );
      }
    }
  }

  Future<void> _loadPdfFromUrl() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load PDF from URL'),
        content: TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: 'Enter PDF URL',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = _urlController.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/pdf_viewer',
                  arguments: {'fileUrl': url},
                );
              }
            },
            child: const Text('Load'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'help':
                  Navigator.pushNamed(context, '/help');
                  break;
                case 'about':
                  Navigator.pushNamed(context, '/about');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'help', child: Text('Help')),
              const PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to ${Constants.appName}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'View, edit, and manage PDF files',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildActionCard(
                context,
                icon: Icons.folder_open,
                title: 'Open PDF from Device',
                subtitle: 'Browse and select a PDF file',
                onTap: _openPdfFromDevice,
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                icon: Icons.link,
                title: 'Load PDF from URL',
                subtitle: 'Enter a URL to load PDF',
                onTap: _loadPdfFromUrl,
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                icon: Icons.history,
                title: 'Recent Files',
                subtitle: 'View recently opened PDFs',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
