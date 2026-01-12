import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;
  late Box recentFoldersBox;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box(Constants.settingsBox);
    recentFoldersBox = Hive.box(Constants.recentFoldersBox);
  }

  bool get darkMode => settingsBox.get(Constants.darkModeKey, defaultValue: true);
  String get scrollbarPosition =>
      settingsBox.get(Constants.scrollbarPositionKey, defaultValue: Constants.scrollbarRight);
  bool get autoSecurityScan =>
      settingsBox.get(Constants.autoSecurityScanKey, defaultValue: true);

  void _toggleDarkMode(bool value) {
    settingsBox.put(Constants.darkModeKey, value);
    setState(() {});
    // Restart app to apply theme change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please restart the app to apply theme changes')),
    );
  }

  void _setScrollbarPosition(String value) {
    settingsBox.put(Constants.scrollbarPositionKey, value);
    setState(() {});
  }

  void _toggleAutoSecurityScan(bool value) {
    settingsBox.put(Constants.autoSecurityScanKey, value);
    setState(() {});
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Hive.box(Constants.cachedPdfsBox).clear();
              Hive.box(Constants.pdfMetadataBox).clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _deleteRecentFolder(String key, int index) {
    final folders = recentFoldersBox.get(key, defaultValue: <String>[]) as List;
    folders.removeAt(index);
    recentFoldersBox.put(key, folders);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: darkMode,
            onChanged: _toggleDarkMode,
          ),
          const Divider(),
          _buildSection('Scrollbar (Android Only)'),
          RadioListTile<String>(
            title: const Text('Disabled'),
            value: Constants.scrollbarDisabled,
            groupValue: scrollbarPosition,
            onChanged: (value) => _setScrollbarPosition(value!),
          ),
          RadioListTile<String>(
            title: const Text('Left Side'),
            value: Constants.scrollbarLeft,
            groupValue: scrollbarPosition,
            onChanged: (value) => _setScrollbarPosition(value!),
          ),
          RadioListTile<String>(
            title: const Text('Right Side'),
            value: Constants.scrollbarRight,
            groupValue: scrollbarPosition,
            onChanged: (value) => _setScrollbarPosition(value!),
          ),
          const Divider(),
          _buildSection('Security'),
          SwitchListTile(
            title: const Text('Auto Security Scan'),
            subtitle: const Text('Automatically scan PDFs for threats'),
            value: autoSecurityScan,
            onChanged: _toggleAutoSecurityScan,
          ),
          const Divider(),
          _buildSection('Recent Folders'),
          _buildRecentFolders(Constants.importFoldersKey, 'Import Folders'),
          _buildRecentFolders(Constants.exportFoldersKey, 'Export Folders'),
          const Divider(),
          _buildSection('Data'),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove cached PDF files'),
            onTap: _clearCache,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildRecentFolders(String key, String title) {
    final folders = recentFoldersBox.get(key, defaultValue: <String>[]) as List;
    
    if (folders.isEmpty) {
      return ListTile(
        title: Text(title),
        subtitle: const Text('No recent folders'),
      );
    }

    return ExpansionTile(
      title: Text(title),
      subtitle: Text('${folders.length} folder(s)'),
      children: folders.asMap().entries.map((entry) {
        final index = entry.key;
        final folder = entry.value as String;
        return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(folder),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteRecentFolder(key, index),
          ),
        );
      }).toList(),
    );
  }
}
