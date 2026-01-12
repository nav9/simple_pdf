class Constants {
  // App Information
  static const String appName = 'Simple PDF';
  static const String appVersion = '1.0.0';
  static const String programmerName = 'Nav';
  
  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String recentFoldersBox = 'recent_folders';
  static const String pdfMetadataBox = 'pdf_metadata';
  static const String cachedPdfsBox = 'cached_pdfs';
  
  // File Size Limits (in bytes)
  static const int maxFileSize = 50 * 1024 * 1024; // 50 MB
  static const int warningFileSize = 10 * 1024 * 1024; // 10 MB
  
  // Supported File Extensions
  static const List<String> pdfExtensions = ['pdf'];
  static const List<String> textExtensions = ['txt'];
  static const List<String> docExtensions = ['doc', 'docx'];
  static const List<String> presentationExtensions = ['ppt', 'pptx'];
  static const List<String> spreadsheetExtensions = ['xls', 'xlsx', 'csv'];
  
  static const List<String> allSupportedExtensions = [
    ...pdfExtensions,
    ...textExtensions,
    ...docExtensions,
    ...presentationExtensions,
    ...spreadsheetExtensions,
  ];
  
  // Settings Keys
  static const String darkModeKey = 'darkMode';
  static const String scrollbarPositionKey = 'scrollbarPosition';
  static const String autoSecurityScanKey = 'autoSecurityScan';
  
  // Scrollbar Position Values
  static const String scrollbarDisabled = 'disabled';
  static const String scrollbarLeft = 'left';
  static const String scrollbarRight = 'right';
  
  // Security Threat Severity Levels
  static const String severityCritical = 'Critical';
  static const String severityHigh = 'High';
  static const String severityMedium = 'Medium';
  static const String severityLow = 'Low';
  
  // Recent Folders Keys
  static const String importFoldersKey = 'import_folders';
  static const String exportFoldersKey = 'export_folders';
  static const int maxRecentFolders = 10;
  
  // PDF Threat Keywords
  static const List<String> javascriptKeywords = ['/JS', '/JavaScript'];
  static const List<String> autoActionKeywords = ['/OpenAction', '/AA'];
  static const List<String> embeddedFileKeywords = ['/EmbeddedFiles', '/EmbeddedFile'];
  static const List<String> uriKeywords = ['/URI'];
  
  // Error Messages
  static const String errorFileNotFound = 'File not found';
  static const String errorFileTooLarge = 'File is too large';
  static const String errorInvalidFormat = 'Invalid file format';
  static const String errorPermissionDenied = 'Permission denied';
  static const String errorNetworkFailure = 'Network connection failed';
  static const String errorUnknown = 'An unknown error occurred';
  
  // Success Messages
  static const String successFileSaved = 'File saved successfully';
  static const String successFileExported = 'File exported successfully';
  static const String successPdfSplit = 'PDF split successfully';
  static const String successPdfMerged = 'PDF merged successfully';
  static const String successTextExtracted = 'Text extracted successfully';
  static const String successImagesExtracted = 'Images extracted successfully';
}
