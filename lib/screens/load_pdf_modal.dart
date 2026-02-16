import 'package:flutter/material.dart';
import 'dart:async';
import '../models/pdf_file_model.dart';
import '../services/database_service.dart';
import 'package:file_picker/file_picker.dart';
import '../services/pdf_security_scanner.dart';
import 'security_analysis_screen.dart';
import '../services/pdf_sandbox_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoadPdfModal extends StatefulWidget {
  const LoadPdfModal({super.key});

  @override
  State<LoadPdfModal> createState() => _LoadPdfModalState();
}

class _LoadPdfModalState extends State<LoadPdfModal> {
  final _databaseService = DatabaseService();
  final _sandboxService = PdfSandboxService();
  final _securityScanner = PdfSecurityScanner();
  final _urlController = TextEditingController();
  
  int _selectedTab = 0; // 0: Database, 1: Browse, 2: URL
  bool _isLoading = false;
  int _dotCount = 0;
  Timer? _loadingTimer;

  void _startLoadingAnimation() {
    _dotCount = 0;
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  void _stopLoadingAnimation() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _stopLoadingAnimation();
    super.dispose();
  }

  Future<void> _browseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isLoading = true;
        });
        _startLoadingAnimation();
        final filePath = result.files.single.path!;
        await _processPdfFile(filePath, result.files.single.name);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _stopLoadingAnimation();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _stopLoadingAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _processPdfFile(String filePath, String fileName) async {
    // Show security scan
    final settings = _databaseService.getSettings();
    
    if (settings.enableMalwareScan) {
      final scanResult = await _securityScanner.scanPdfFile(filePath);
      
      if (mounted) {
        final shouldOpen = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => SecurityAnalysisScreen(
              scanResult: scanResult,
              fileName: fileName,
            ),
          ),
        );

        if (shouldOpen != true) return;
      }
    }

    // Copy to sandbox and add to database
    final pdfId = const Uuid().v4();
    final sandboxPath = await _sandboxService.copyPdfToSandbox(filePath, pdfId);
    final fileSize = await _sandboxService.getFileSize(sandboxPath);

    final pdf = PdfFileModel(
      id: pdfId,
      name: fileName,
      filePath: sandboxPath,
      dateAdded: DateTime.now(),
      dateModified: DateTime.now(),
      fileSize: fileSize,
    );

    await _databaseService.addPdf(pdf);

    if (mounted) {
      Navigator.pop(context, pdf);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Load PDF',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Database')),
              ButtonSegment(value: 1, label: Text('Browse')),
              ButtonSegment(value: 2, label: Text('URL')),
            ],
            selected: {_selectedTab},
            onSelectionChanged: (Set<int> newSelection) {
              if (!_isLoading) {
                 setState(() {
                   _selectedTab = newSelection.first;
                 });
              }
            },
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Loading${'.' * _dotCount}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildDatabaseTab();
      case 1:
        return _buildBrowseTab();
      case 2:
        return _buildUrlTab();
      default:
        return Container();
    }
  }


  void _selectPdfFromDatabase(PdfFileModel pdf) {
    if (mounted) {
      Navigator.pop(context, pdf);
    }
  }

  Future<void> _renamePdf(PdfFileModel pdf) async {
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
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != pdf.name) {
      pdf.name = newName;
      await _databaseService.updatePdf(pdf);
      setState(() {});
    }
  }

  Future<void> _deletePdf(PdfFileModel pdf) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PDF'),
        content: Text('Are you sure you want to delete "${pdf.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _databaseService.deletePdf(pdf.id);
      setState(() {});
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDatabaseTab() {
    final pdfs = _databaseService.getAllPdfs();

    if (pdfs.isEmpty) {
      return const Center(
        child: Text('No PDFs in database'),
      );
    }

    return ListView.builder(
      itemCount: pdfs.length,
      itemBuilder: (context, index) {
        final pdf = pdfs[index];
        return ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(pdf.name),
          subtitle: Text('${(pdf.fileSize / 1024 / 1024).toStringAsFixed(2)} MB • ${_formatDate(pdf.dateAdded)}'),
          onTap: () => _selectPdfFromDatabase(pdf),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rename') {
                _renamePdf(pdf);
              } else if (value == 'delete') {
                _deletePdf(pdf);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Rename'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrowseTab() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _browseFile,
        icon: const Icon(Icons.folder_open),
        label: const Text('Browse Files'),
      ),
    );
  }

  Widget _buildUrlTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: 'PDF URL',
            hintText: 'https://example.com/document.pdf',
            hintStyle: TextStyle(color: Colors.grey.shade700),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.paste),
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  _urlController.text = data!.text!;
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _downloadPdf,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Download',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadPdf() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a URL')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      _startLoadingAnimation();

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = url.split('/').last.split('?').first; // Basic filename extraction
        final name = fileName.endsWith('.pdf') ? fileName : 'downloaded.pdf';
        final file = File('${tempDir.path}/$name');
        await file.writeAsBytes(response.bodyBytes);

        // Process the downloaded file (includes security scan)
        await _processPdfFile(file.path, name);
        
        if (mounted) {
             setState(() {
            _isLoading = false;
          });
          _stopLoadingAnimation();
        }
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _stopLoadingAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading PDF: $e')),
        );
      }
    }
  }
}
