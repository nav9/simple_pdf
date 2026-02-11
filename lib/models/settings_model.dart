import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String pdfViewerPackage; // 'pdfrx' or 'easy_pdf_viewer'

  @HiveField(1)
  String theme; // 'dark', 'light', 'system'

  @HiveField(2)
  bool enableMalwareScan;

  @HiveField(3)
  bool loadFullPdf;

  @HiveField(4)
  String? ttsVoice;

  @HiveField(5)
  double ttsSpeed;

  @HiveField(6)
  double ttsPitch;

  @HiveField(7)
  bool plausibleDeniabilityEnabled;

  @HiveField(8)
  bool useDarkPdfBackground;

  @HiveField(9)
  double scrollPhysics; // 0.0 to 1.0 for scroll sensitivity

  @HiveField(10)
  double zoomPhysics; // 0.0 to 1.0 for zoom sensitivity

  SettingsModel({
    this.pdfViewerPackage = 'pdfrx',
    this.theme = 'dark',
    this.enableMalwareScan = true,
    this.loadFullPdf = false,
    this.ttsVoice,
    this.ttsSpeed = 1.0,
    this.ttsPitch = 1.0,
    this.plausibleDeniabilityEnabled = false,
    this.useDarkPdfBackground = false,
    this.scrollPhysics = 0.5,
    this.zoomPhysics = 0.5,
  });

  Map<String, dynamic> toJson() => {
        'pdfViewerPackage': pdfViewerPackage,
        'theme': theme,
        'enableMalwareScan': enableMalwareScan,
        'loadFullPdf': loadFullPdf,
        'ttsVoice': ttsVoice,
        'ttsSpeed': ttsSpeed,
        'ttsPitch': ttsPitch,
        'plausibleDeniabilityEnabled': plausibleDeniabilityEnabled,
        'useDarkPdfBackground': useDarkPdfBackground,
        'scrollPhysics': scrollPhysics,
        'zoomPhysics': zoomPhysics,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        pdfViewerPackage: json['pdfViewerPackage'] ?? 'pdfrx',
        theme: json['theme'] ?? 'dark',
        enableMalwareScan: json['enableMalwareScan'] ?? true,
        loadFullPdf: json['loadFullPdf'] ?? false,
        ttsVoice: json['ttsVoice'],
        ttsSpeed: json['ttsSpeed'] ?? 1.0,
        ttsPitch: json['ttsPitch'] ?? 1.0,
        plausibleDeniabilityEnabled:
            json['plausibleDeniabilityEnabled'] ?? false,
        useDarkPdfBackground: json['useDarkPdfBackground'] ?? false,
        scrollPhysics: json['scrollPhysics'] ?? 0.5,
        zoomPhysics: json['zoomPhysics'] ?? 0.5,
      );
}
