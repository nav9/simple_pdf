class SecurityThreat {
  final String type;
  final String severity;
  final String description;
  final String location;
  final String recommendation;

  SecurityThreat({
    required this.type,
    required this.severity,
    required this.description,
    required this.location,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'description': description,
      'location': location,
      'recommendation': recommendation,
    };
  }

  factory SecurityThreat.fromJson(Map<String, dynamic> json) {
    return SecurityThreat(
      type: json['type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      recommendation: json['recommendation'] as String,
    );
  }

  bool get isCritical => severity == 'Critical';
  bool get isHigh => severity == 'High';
  bool get isMedium => severity == 'Medium';
  bool get isLow => severity == 'Low';
}

class SecurityAnalysisResult {
  final List<SecurityThreat> threats;
  final DateTime analyzedAt;
  final String filePath;

  SecurityAnalysisResult({
    required this.threats,
    required this.analyzedAt,
    required this.filePath,
  });

  bool get hasThreats => threats.isNotEmpty;
  bool get hasCriticalThreats => threats.any((t) => t.isCritical);
  bool get hasHighThreats => threats.any((t) => t.isHigh);

  List<SecurityThreat> get criticalThreats =>
      threats.where((t) => t.isCritical).toList();
  List<SecurityThreat> get highThreats =>
      threats.where((t) => t.isHigh).toList();
  List<SecurityThreat> get mediumThreats =>
      threats.where((t) => t.isMedium).toList();
  List<SecurityThreat> get lowThreats =>
      threats.where((t) => t.isLow).toList();

  Map<String, dynamic> toJson() {
    return {
      'threats': threats.map((t) => t.toJson()).toList(),
      'analyzedAt': analyzedAt.toIso8601String(),
      'filePath': filePath,
    };
  }

  factory SecurityAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SecurityAnalysisResult(
      threats: (json['threats'] as List)
          .map((t) => SecurityThreat.fromJson(t as Map<String, dynamic>))
          .toList(),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      filePath: json['filePath'] as String,
    );
  }
}
