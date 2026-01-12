import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpSection(
            context,
            title: 'Opening PDFs',
            items: [
              'Tap "Open PDF from Device" to browse and select a PDF file from your device',
              'Tap "Load PDF from URL" to enter a web address and load a PDF from the internet',
              'Recently opened files will appear in "Recent Files" for quick access',
            ],
          ),
          _buildHelpSection(
            context,
            title: 'Viewing PDFs',
            items: [
              'Pinch to zoom in and out of PDF pages',
              'Tap the fullscreen icon to enter fullscreen mode',
              'Tap the color inversion icon to switch between normal and inverted colors',
              'Swipe left or right to navigate between pages',
            ],
          ),
          _buildHelpSection(
            context,
            title: 'Security Analysis',
            items: [
              'When opening a PDF, you may be prompted to scan for security threats',
              'The app checks for JavaScript, auto-actions, embedded files, and other potential risks',
              'Threats are categorized by severity: Critical, High, Medium, and Low',
              'You can choose to proceed with opening the file or cancel',
              'Enable/disable automatic security scanning in Settings',
            ],
          ),
          _buildHelpSection(
            context,
            title: 'Splitting PDFs',
            items: [
              'Open a PDF and tap the menu icon',
              'Select "Split PDF"',
              'Choose which pages to extract by checking the boxes',
              'Select a save location',
              'The new PDF will be created with only the selected pages',
            ],
          ),
          _buildHelpSection(
            context,
            title: 'Merging PDFs',
            items: [
              'From the home screen, tap "Merge PDFs"',
              'Select multiple PDF files',
              'Choose pages from each file',
              'Arrange pages in the desired order',
              'Select a save location and confirm',
            ],
          ),
          _buildHelpSection(
            context,
            title: 'Extracting Content',
            items: [
              'Open a PDF and tap the menu icon',
              'Select "Extract Text" or "Extract Images"',
              'Choose to save to filesystem or database',
              'If saving to filesystem, select a folder',
              'The app will request permissions if needed',
            ],
          ),
          _buildHelpSection(
            context,
            title: 'Converting Documents',
            items: [
              'Open a PDF and tap the menu icon',
              'Select "Convert"',
              'Choose the output format (TXT, DOC, DOCX, PPT, etc.)',
              'Select a save location',
              'Note: Some formats may require cloud processing',
            ],
          ),
          _buildHelpSection(
            context,
            title: 'Settings',
            items: [
              'Access Settings from the home screen menu',
              'Toggle between light and dark themes',
              'Adjust scrollbar position (Android only)',
              'Enable/disable automatic security scanning',
              'Manage recent folders',
              'Clear cached data',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
