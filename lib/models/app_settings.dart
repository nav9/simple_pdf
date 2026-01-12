class AppSettings {
  final bool darkMode;
  final String scrollbarPosition;
  final bool autoSecurityScan;

  AppSettings({
    this.darkMode = true,
    this.scrollbarPosition = 'right',
    this.autoSecurityScan = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'scrollbarPosition': scrollbarPosition,
      'autoSecurityScan': autoSecurityScan,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      darkMode: json['darkMode'] as bool? ?? true,
      scrollbarPosition: json['scrollbarPosition'] as String? ?? 'right',
      autoSecurityScan: json['autoSecurityScan'] as bool? ?? true,
    );
  }

  AppSettings copyWith({
    bool? darkMode,
    String? scrollbarPosition,
    bool? autoSecurityScan,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      scrollbarPosition: scrollbarPosition ?? this.scrollbarPosition,
      autoSecurityScan: autoSecurityScan ?? this.autoSecurityScan,
    );
  }

  static AppSettings get defaultSettings => AppSettings();
}
