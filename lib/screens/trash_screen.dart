import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/pdf_file_model.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final _databaseService = DatabaseService();
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final trashPdfs = _databaseService.getTrashPdfs();
    final allSelected = trashPdfs.isNotEmpty && _selectedIds.length == trashPdfs.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (trashPdfs.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  if (allSelected) {
                    _selectedIds.clear();
                  } else {
                    _selectedIds.addAll(trashPdfs.map((p) => p.id));
                  }
                });
              },
              child: Text(
                allSelected ? 'Select None' : 'Select All',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          if (_selectedIds.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Restore',
              onPressed: () async {
                for (var id in _selectedIds) {
                  await _databaseService.restorePdfFromTrash(id);
                }
                setState(() {
                  _selectedIds.clear();
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDFs restored')),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete Permanently',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Permanently'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  for (var id in _selectedIds) {
                    await _databaseService.deletePdf(id);
                  }
                  setState(() {
                    _selectedIds.clear();
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDFs deleted permanently')),
                    );
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: trashPdfs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Trash is empty',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: trashPdfs.length,
              itemBuilder: (context, index) {
                final pdf = trashPdfs[index];
                final isSelected = _selectedIds.contains(pdf.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(pdf.id);
                      } else {
                        _selectedIds.remove(pdf.id);
                      }
                    });
                  },
                  title: Text(pdf.name),
                  subtitle: Text('${(pdf.fileSize / 1024 / 1024).toStringAsFixed(2)} MB'),
                  secondary: const Icon(Icons.picture_as_pdf),
                );
              },
            ),
    );
  }
}
