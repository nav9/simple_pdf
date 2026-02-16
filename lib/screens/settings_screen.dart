import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../models/settings_model.dart';
import '../utils/platform_utils.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _databaseService = DatabaseService();
  final _encryptionService = EncryptionService();
  late SettingsModel _settings;
  bool _plausibleDeniabilityEnabled = false;
  List<dynamic> _availableVoices = [];
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVoices();
  }

  Future<void> _loadSettings() async {
    _settings = _databaseService.getSettings();
    _plausibleDeniabilityEnabled =
        await _encryptionService.isPlausibleDeniabilityEnabled();
    setState(() {});
  }

  Future<void> _loadVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      setState(() {
        _availableVoices = voices ?? [];
      });
    } catch (e) {
      print('Error loading voices: $e');
    }
  }

  Future<void> _saveSettings() async {
    await _databaseService.updateSettings(_settings);
  }

  Future<void> _setupPlausibleDeniability() async {
    final realPasswordController = TextEditingController();
    final fakePasswordController = TextEditingController();
    final realPasswordConfirmController = TextEditingController();
    final fakePasswordConfirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Plausible Deniability'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create two passwords:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Real password: Access your actual PDFs'),
              const Text('• Fake password: Access decoy PDFs'),
              const SizedBox(height: 16),
              TextField(
                controller: realPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Real Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: realPasswordConfirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Real Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fakePasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Fake Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fakePasswordConfirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Fake Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (realPasswordController.text !=
                  realPasswordConfirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Real passwords do not match')),
                );
                return;
              }
              if (fakePasswordController.text !=
                  fakePasswordConfirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Fake passwords do not match')),
                );
                return;
              }
              if (realPasswordController.text.isEmpty ||
                  fakePasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Passwords cannot be empty')),
                );
                return;
              }
              if (realPasswordController.text ==
                  fakePasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Real and fake passwords must be different')),
                );
                return;
              }

              await _encryptionService.setupPlausibleDeniability(
                realPassword: realPasswordController.text,
                fakePassword: fakePasswordController.text,
              );

              Navigator.pop(context, true);
            },
            child: const Text('Setup'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _plausibleDeniabilityEnabled = true;
        _settings.plausibleDeniabilityEnabled = true;
      });
      await _saveSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Plausible deniability enabled. App will require password on next launch.')),
        );
      }
    }
  }

  Future<void> _disablePlausibleDeniability() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Plausible Deniability'),
        content: const Text(
            'This will remove password protection and merge all databases. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _encryptionService.disablePlausibleDeniability();
      setState(() {
        _plausibleDeniabilityEnabled = false;
        _settings.plausibleDeniabilityEnabled = false;
      });
      await _saveSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plausible deniability disabled')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableViewers = PlatformUtils.availablePdfViewers;
    final currentMode = _databaseService.currentMode;
    final showPlausibleDeniability = currentMode == 'real';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Security Section
          if (showPlausibleDeniability) ...[
            const ListTile(
              title: Text(
                'Security',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Plausible Deniability'),
              subtitle: const Text('Dual password system for hidden PDFs'),
              value: _plausibleDeniabilityEnabled,
              onChanged: (value) {
                if (value) {
                  _setupPlausibleDeniability();
                } else {
                  _disablePlausibleDeniability();
                }
              },
            ),
            const Divider(),
          ],

          // PDF Viewer Section
          const ListTile(
            title: Text(
              'PDF Viewer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            title: const Text('Set as Default PDF App'),
            subtitle: const Text('Open system settings to manage defaults'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              // Using permission_handler's openAppSettings
              await openAppSettings();
            },
          ),
          if (availableViewers.length > 1)
            ListTile(
              title: const Text('PDF Viewer Package'),
              subtitle: Text(_settings.pdfViewerPackage),
              trailing: DropdownButton<String>(
                value: _settings.pdfViewerPackage,
                items: availableViewers.map((viewer) {
                  return DropdownMenuItem(
                    value: viewer,
                    child: Text(viewer),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _settings.pdfViewerPackage = value;
                    });
                    _saveSettings();
                  }
                },
              ),
            ),
          SwitchListTile(
            title: const Text('Dark PDF Background'),
            subtitle: const Text('Invert PDF colors for dark mode'),
            value: _settings.useDarkPdfBackground,
            onChanged: (value) {
              setState(() {
                _settings.useDarkPdfBackground = value;
              });
              _saveSettings();
            },
          ),
          const Divider(),

          // Appearance Section
          const ListTile(
            title: Text(
              'Appearance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_settings.theme),
            trailing: DropdownButton<String>(
              value: _settings.theme,
              items: const [
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _settings.theme = value;
                  });
                  _saveSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Restart app to apply theme changes')),
                  );
                }
              },
            ),
          ),
          const Divider(),

          // Text-to-Speech Section
          const ListTile(
            title: Text(
              'Text-to-Speech',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (_availableVoices.isNotEmpty)
            ListTile(
              title: const Text('Voice'),
              subtitle: Text(_settings.ttsVoice ?? 'Default'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final selected = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Voice'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableVoices.length,
                        itemBuilder: (context, index) {
                          final voice = _availableVoices[index];
                          final voiceName = voice['name'] ?? 'Unknown';
                          return ListTile(
                            title: Text(voiceName),
                            onTap: () => Navigator.pop(context, voiceName),
                          );
                        },
                      ),
                    ),
                  ),
                );
                if (selected != null) {
                  setState(() {
                    _settings.ttsVoice = selected;
                  });
                  _saveSettings();
                }
              },
            ),
          ListTile(
            title: const Text('Speech Speed'),
            subtitle: Text(_settings.ttsSpeed.toStringAsFixed(1)),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _settings.ttsSpeed,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                label: _settings.ttsSpeed.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _settings.ttsSpeed = value;
                  });
                },
                onChangeEnd: (value) => _saveSettings(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Speech Pitch'),
            subtitle: Text(_settings.ttsPitch.toStringAsFixed(1)),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _settings.ttsPitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                label: _settings.ttsPitch.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _settings.ttsPitch = value;
                  });
                },
                onChangeEnd: (value) => _saveSettings(),
              ),
            ),
          ),
          const Divider(),

          // Performance Section
          const ListTile(
            title: Text(
              'Performance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Malware Scan'),
            subtitle: const Text('Scan PDFs before opening'),
            value: _settings.enableMalwareScan,
            onChanged: (value) {
              setState(() {
                _settings.enableMalwareScan = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Load Full PDF'),
            subtitle: const Text('Load entire PDF vs page-by-page'),
            value: _settings.loadFullPdf,
            onChanged: (value) {
              setState(() {
                _settings.loadFullPdf = value;
              });
              _saveSettings();
            },
          ),
          ListTile(
            title: const Text('Scroll Sensitivity'),
            subtitle: Text(_settings.scrollPhysics.toStringAsFixed(2)),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _settings.scrollPhysics,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: _settings.scrollPhysics.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _settings.scrollPhysics = value;
                  });
                },
                onChangeEnd: (value) => _saveSettings(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Zoom Sensitivity'),
            subtitle: Text(_settings.zoomPhysics.toStringAsFixed(2)),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _settings.zoomPhysics,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: _settings.zoomPhysics.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _settings.zoomPhysics = value;
                  });
                },
                onChangeEnd: (value) => _saveSettings(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
