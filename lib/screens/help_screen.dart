import 'package:flutter/material.dart';

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
          _buildSection(
            context,
            'Getting Started',
            [
              'Simple PDF is a secure PDF viewer with advanced features for Linux and Android.',
              'Load PDFs from your device, URLs, or the app database.',
              'All PDFs are stored securely in the app database for sandboxed viewing.',
            ],
          ),
          _buildSection(
            context,
            'Loading PDFs',
            [
              '• Tap the folder icon to open the Load PDF modal',
              '• Database tab: View and open PDFs already in the app',
              '• Browse tab: Pick a PDF file from your device',
              '• URL tab: Download a PDF from the internet',
              '• All loaded PDFs are scanned for malware before opening',
            ],
          ),
          _buildSection(
            context,
            'Security Features',
            [
              '• Malware Scanner: Detects JavaScript, launch actions, and other threats',
              '• Sandboxed Storage: PDFs have no access to your filesystem',
              '• Plausible Deniability: Create a fake password to hide sensitive PDFs',
              '• Encryption: Store PDFs in encrypted form',
            ],
          ),
          _buildSection(
            context,
            'Viewing PDFs',
            [
              '• Multiple PDFs: Open multiple PDFs in tabs',
              '• Zoom: Pinch to zoom or use Ctrl+Mouse Scroll (Linux)',
              '• Navigation: Swipe pages or use arrow keys (Linux)',
              '• Dark Mode: Toggle dark PDF background in overflow menu',
              '• Fullscreen: View PDFs in fullscreen mode',
            ],
          ),
          _buildSection(
            context,
            'PDF Operations',
            [
              '• Search: Find text in PDFs with highlighting',
              '• Bookmarks: Create, edit, and navigate to bookmarks',
              '• Extract: Save text or images from PDFs',
              '• Merge: Select and merge specific pages',
              '• Rename: Rename PDFs in the database',
              '• Move to Trash: Safely delete PDFs',
            ],
          ),
          _buildSection(
            context,
            'Text-to-Speech',
            [
              '• Read PDF text aloud with customizable voice',
              '• Adjust speed and pitch in Settings',
              '• Select from available system voices',
            ],
          ),
          _buildSection(
            context,
            'Settings',
            [
              '• PDF Viewer: Choose between pdfrx and easy_pdf_viewer',
              '• Theme: Switch between dark, light, or system theme',
              '• Security: Enable/disable malware scanning',
              '• Performance: Adjust scroll/zoom sensitivity',
              '• Plausible Deniability: Set up dual password system',
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'FAQ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildFAQ(
            context,
            'How does plausible deniability work?',
            'You create two passwords: a real password and a fake password. '
                'When you enter the real password, you see your actual PDFs. '
                'When you enter the fake password, you see a different set of decoy PDFs. '
                'This provides protection if you\'re forced to reveal your password.',
          ),
          _buildFAQ(
            context,
            'Is the malware scanner reliable?',
            'The scanner detects common PDF threats like JavaScript, launch actions, '
                'and suspicious URLs. However, it\'s not as comprehensive as commercial '
                'antivirus software. Always be cautious with PDFs from unknown sources.',
          ),
          _buildFAQ(
            context,
            'Can PDFs access the internet?',
            'No. PDFs are stored in the app\'s private storage and cannot access '
                'the internet or your filesystem. This sandboxing provides security '
                'against malicious PDFs.',
          ),
          _buildFAQ(
            context,
            'What happens to deleted PDFs?',
            'Deleted PDFs are moved to Trash where they can be restored or '
                'permanently deleted. Permanently deleted PDFs cannot be recovered.',
          ),
          _buildFAQ(
            context,
            'How do I export a PDF?',
            'Use the "Save to Storage" option in the overflow menu to export '
                'a PDF from the database to your device storage.',
          ),
          _buildFAQ(
            context,
            'What PDF formats are supported?',
            'The app supports standard PDF files (.pdf). Encrypted PDFs may '
                'require decryption before viewing.',
          ),
          _buildFAQ(
            context,
            'Can I use keyboard shortcuts?',
            'Yes, on Linux you can use:\n'
                '• Arrow keys / Page Up/Down: Navigate pages\n'
                '• Ctrl + Mouse Scroll: Zoom in/out\n'
                '• Ctrl + F: Search (when implemented)',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(point),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFAQ(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
