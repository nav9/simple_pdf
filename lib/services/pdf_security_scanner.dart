import 'dart:io';
import 'dart:typed_data';

enum ThreatLevel {
  critical,
  high,
  medium,
  low,
  none,
}

class ThreatInfo {
  final String type;
  final ThreatLevel level;
  final String description;
  final String recommendation;
  final List<String> details;

  ThreatInfo({
    required this.type,
    required this.level,
    required this.description,
    required this.recommendation,
    this.details = const [],
  });
}

class SecurityScanResult {
  final List<ThreatInfo> threats;
  final bool isSafe;
  final String summary;

  SecurityScanResult({
    required this.threats,
    required this.isSafe,
    required this.summary,
  });

  ThreatLevel get highestThreatLevel {
    if (threats.isEmpty) return ThreatLevel.none;
    
    var highest = ThreatLevel.none;
    for (var threat in threats) {
      if (threat.level.index > highest.index) {
        highest = threat.level;
      }
    }
    return highest;
  }
}

class PdfSecurityScanner {
  static final PdfSecurityScanner _instance = PdfSecurityScanner._internal();
  factory PdfSecurityScanner() => _instance;
  PdfSecurityScanner._internal();

  /// Scan PDF file for potential security threats
  Future<SecurityScanResult> scanPdfFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return scanPdfBytes(bytes);
  }

  /// Scan PDF bytes for potential security threats
  Future<SecurityScanResult> scanPdfBytes(Uint8List bytes) async {
    final threats = <ThreatInfo>[];
    final content = String.fromCharCodes(bytes);

    // Check for JavaScript
    if (_containsJavaScript(content)) {
      threats.add(ThreatInfo(
        type: 'JavaScript',
        level: ThreatLevel.high,
        description: 'This PDF contains JavaScript code',
        recommendation:
            'JavaScript in PDFs can be used for malicious purposes. Open with caution or disable JavaScript in your PDF viewer.',
        details: _extractJavaScriptDetails(content),
      ));
    }

    // Check for Launch actions
    if (_containsLaunchAction(content)) {
      threats.add(ThreatInfo(
        type: 'Launch Action',
        level: ThreatLevel.critical,
        description: 'This PDF attempts to launch external programs',
        recommendation:
            'Launch actions can execute programs on your system. Do not open this PDF unless you trust the source.',
        details: ['PDF contains /Launch action'],
      ));
    }

    // Check for URI/URL actions
    if (_containsUriAction(content)) {
      threats.add(ThreatInfo(
        type: 'URI/URL Action',
        level: ThreatLevel.medium,
        description: 'This PDF contains links to external websites',
        recommendation:
            'The PDF may attempt to connect to external URLs. Be cautious when clicking links.',
        details: _extractUriDetails(content),
      ));
    }

    // Check for embedded files
    if (_containsEmbeddedFiles(content)) {
      threats.add(ThreatInfo(
        type: 'Embedded Files',
        level: ThreatLevel.medium,
        description: 'This PDF contains embedded files',
        recommendation:
            'Embedded files could contain malware. Extract and scan them separately before opening.',
        details: ['PDF contains /EmbeddedFile objects'],
      ));
    }

    // Check for form actions
    if (_containsFormActions(content)) {
      threats.add(ThreatInfo(
        type: 'Form Actions',
        level: ThreatLevel.low,
        description: 'This PDF contains form submission actions',
        recommendation:
            'Forms may submit data to external servers. Review form fields before submitting.',
        details: ['PDF contains /SubmitForm or /ImportData actions'],
      ));
    }

    // Check for auto-actions
    if (_containsAutoActions(content)) {
      threats.add(ThreatInfo(
        type: 'Auto Actions',
        level: ThreatLevel.high,
        description: 'This PDF has actions that execute automatically',
        recommendation:
            'Auto-actions can execute without user interaction. Open with extreme caution.',
        details: ['PDF contains /OpenAction or /AA (Additional Actions)'],
      ));
    }

    // Determine if PDF is safe
    final isSafe = threats.isEmpty ||
        threats.every((t) => t.level == ThreatLevel.low);

    // Generate summary
    final summary = _generateSummary(threats, isSafe);

    return SecurityScanResult(
      threats: threats,
      isSafe: isSafe,
      summary: summary,
    );
  }

  bool _containsJavaScript(String content) {
    return content.contains('/JavaScript') || content.contains('/JS');
  }

  List<String> _extractJavaScriptDetails(String content) {
    final details = <String>[];
    if (content.contains('/JavaScript')) {
      details.add('Contains /JavaScript object');
    }
    if (content.contains('/JS')) {
      details.add('Contains /JS reference');
    }
    return details;
  }

  bool _containsLaunchAction(String content) {
    return content.contains('/Launch');
  }

  bool _containsUriAction(String content) {
    return content.contains('/URI');
  }

  List<String> _extractUriDetails(String content) {
    final details = <String>[];
    final uriPattern = RegExp(r'/URI\s*\(([^)]+)\)');
    final matches = uriPattern.allMatches(content);
    
    for (var match in matches) {
      final url = match.group(1);
      if (url != null) {
        details.add('URL: $url');
      }
    }
    
    return details.isEmpty ? ['PDF contains /URI actions'] : details;
  }

  bool _containsEmbeddedFiles(String content) {
    return content.contains('/EmbeddedFile');
  }

  bool _containsFormActions(String content) {
    return content.contains('/SubmitForm') || content.contains('/ImportData');
  }

  bool _containsAutoActions(String content) {
    return content.contains('/OpenAction') || content.contains('/AA');
  }

  String _generateSummary(List<ThreatInfo> threats, bool isSafe) {
    if (threats.isEmpty) {
      return 'No security threats detected. This PDF appears to be safe.';
    }

    final criticalCount =
        threats.where((t) => t.level == ThreatLevel.critical).length;
    final highCount = threats.where((t) => t.level == ThreatLevel.high).length;
    final mediumCount =
        threats.where((t) => t.level == ThreatLevel.medium).length;
    final lowCount = threats.where((t) => t.level == ThreatLevel.low).length;

    final parts = <String>[];
    if (criticalCount > 0) {
      parts.add('$criticalCount critical threat${criticalCount > 1 ? 's' : ''}');
    }
    if (highCount > 0) {
      parts.add('$highCount high threat${highCount > 1 ? 's' : ''}');
    }
    if (mediumCount > 0) {
      parts.add('$mediumCount medium threat${mediumCount > 1 ? 's' : ''}');
    }
    if (lowCount > 0) {
      parts.add('$lowCount low threat${lowCount > 1 ? 's' : ''}');
    }

    return 'Found ${parts.join(', ')}. ${isSafe ? 'PDF may be safe to open with caution.' : 'Exercise extreme caution when opening this PDF.'}';
  }
}
