class PdfDocument {
  final String id;
  final String fileName;
  final String? filePath;
  final String? fileUrl;
  final int fileSize;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final bool isFromUrl;
  final bool isCached;

  PdfDocument({
    required this.id,
    required this.fileName,
    this.filePath,
    this.fileUrl,
    required this.fileSize,
    required this.createdAt,
    required this.lastAccessed,
    this.isFromUrl = false,
    this.isCached = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessed': lastAccessed.toIso8601String(),
      'isFromUrl': isFromUrl,
      'isCached': isCached,
    };
  }

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    return PdfDocument(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String?,
      fileUrl: json['fileUrl'] as String?,
      fileSize: json['fileSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      isFromUrl: json['isFromUrl'] as bool? ?? false,
      isCached: json['isCached'] as bool? ?? false,
    );
  }

  PdfDocument copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? fileUrl,
    int? fileSize,
    DateTime? createdAt,
    DateTime? lastAccessed,
    bool? isFromUrl,
    bool? isCached,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isFromUrl: isFromUrl ?? this.isFromUrl,
      isCached: isCached ?? this.isCached,
    );
  }

  String get displaySize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
