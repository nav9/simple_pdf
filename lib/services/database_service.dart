import 'package:hive_flutter/hive_flutter.dart';
import '../models/pdf_file_model.dart';
import '../models/bookmark_model.dart';
import '../models/settings_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Box names
  static const String _realPdfBoxName = 'real_pdfs';
  static const String _fakePdfBoxName = 'fake_pdfs';
  static const String _realBookmarkBoxName = 'real_bookmarks';
  static const String _fakeBookmarkBoxName = 'fake_bookmarks';
  static const String _settingsBoxName = 'settings';

  // Current database mode
  String _currentMode = 'real'; // 'real' or 'fake'

  // Boxes
  Box<PdfFileModel>? _pdfBox;
  Box<BookmarkModel>? _bookmarkBox;
  Box<SettingsModel>? _settingsBox;

  /// Initialize Hive and register adapters
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PdfFileModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BookmarkModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }

    // Open settings box (shared between real and fake modes)
    _settingsBox = await Hive.openBox<SettingsModel>(_settingsBoxName);
    
    // Initialize with default settings if empty
    if (_settingsBox!.isEmpty) {
      await _settingsBox!.put('default', SettingsModel());
    }

    // Open real database by default
    await switchDatabase('real');
  }

  /// Switch between real and fake databases
  Future<void> switchDatabase(String mode) async {
    _currentMode = mode;
    
    // Close existing boxes if open
    if (_pdfBox?.isOpen ?? false) await _pdfBox!.close();
    if (_bookmarkBox?.isOpen ?? false) await _bookmarkBox!.close();

    // Open appropriate boxes
    final pdfBoxName = mode == 'real' ? _realPdfBoxName : _fakePdfBoxName;
    final bookmarkBoxName = mode == 'real' ? _realBookmarkBoxName : _fakeBookmarkBoxName;

    _pdfBox = await Hive.openBox<PdfFileModel>(pdfBoxName);
    _bookmarkBox = await Hive.openBox<BookmarkModel>(bookmarkBoxName);
  }

  /// Get current database mode
  String get currentMode => _currentMode;

  // ===== PDF Operations =====

  /// Add PDF to database
  Future<void> addPdf(PdfFileModel pdf) async {
    await _pdfBox!.put(pdf.id, pdf);
  }

  /// Get PDF by ID
  PdfFileModel? getPdf(String id) {
    return _pdfBox!.get(id);
  }

  /// Get all PDFs (excluding trash)
  List<PdfFileModel> getAllPdfs() {
    return _pdfBox!.values.where((pdf) => !pdf.isInTrash).toList();
  }

  /// Get all PDFs in trash
  List<PdfFileModel> getTrashPdfs() {
    return _pdfBox!.values.where((pdf) => pdf.isInTrash).toList();
  }

  /// Update PDF
  Future<void> updatePdf(PdfFileModel pdf) async {
    await _pdfBox!.put(pdf.id, pdf);
  }

  /// Move PDF to trash
  Future<void> movePdfToTrash(String id) async {
    final pdf = _pdfBox!.get(id);
    if (pdf != null) {
      pdf.isInTrash = true;
      await _pdfBox!.put(id, pdf);
    }
  }

  /// Restore PDF from trash
  Future<void> restorePdfFromTrash(String id) async {
    final pdf = _pdfBox!.get(id);
    if (pdf != null) {
      pdf.isInTrash = false;
      await _pdfBox!.put(id, pdf);
    }
  }

  /// Delete PDF permanently
  Future<void> deletePdf(String id) async {
    await _pdfBox!.delete(id);
    
    // Also delete associated bookmarks
    final bookmarks = getBookmarksForPdf(id);
    for (var bookmark in bookmarks) {
      await deleteBookmark(bookmark.id);
    }
  }

  // ===== Bookmark Operations =====

  /// Add bookmark
  Future<void> addBookmark(BookmarkModel bookmark) async {
    await _bookmarkBox!.put(bookmark.id, bookmark);
  }

  /// Get bookmark by ID
  BookmarkModel? getBookmark(String id) {
    return _bookmarkBox!.get(id);
  }

  /// Get all bookmarks for a PDF
  List<BookmarkModel> getBookmarksForPdf(String pdfId) {
    return _bookmarkBox!.values
        .where((bookmark) => bookmark.pdfId == pdfId)
        .toList()
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
  }

  /// Get all bookmarks
  List<BookmarkModel> getAllBookmarks() {
    return _bookmarkBox!.values.toList();
  }

  /// Update bookmark
  Future<void> updateBookmark(BookmarkModel bookmark) async {
    await _bookmarkBox!.put(bookmark.id, bookmark);
  }

  /// Delete bookmark
  Future<void> deleteBookmark(String id) async {
    await _bookmarkBox!.delete(id);
  }

  // ===== Settings Operations =====

  /// Get settings
  SettingsModel getSettings() {
    return _settingsBox!.get('default') ?? SettingsModel();
  }

  /// Update settings
  Future<void> updateSettings(SettingsModel settings) async {
    await _settingsBox!.put('default', settings);
  }

  /// Close all boxes
  Future<void> close() async {
    await _pdfBox?.close();
    await _bookmarkBox?.close();
    await _settingsBox?.close();
  }
}
