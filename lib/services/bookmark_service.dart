import 'package:uuid/uuid.dart';
import '../models/bookmark_model.dart';
import 'database_service.dart';

class BookmarkService {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  final _databaseService = DatabaseService();
  final _uuid = const Uuid();

  /// Create a new bookmark
  Future<BookmarkModel> createBookmark({
    required String pdfId,
    required String name,
    required int pageNumber,
  }) async {
    final bookmark = BookmarkModel(
      id: _uuid.v4(),
      pdfId: pdfId,
      name: name,
      pageNumber: pageNumber,
      dateCreated: DateTime.now(),
    );

    await _databaseService.addBookmark(bookmark);
    return bookmark;
  }

  /// Get all bookmarks for a PDF
  List<BookmarkModel> getBookmarksForPdf(String pdfId) {
    return _databaseService.getBookmarksForPdf(pdfId);
  }

  /// Update bookmark name
  Future<void> updateBookmarkName(String bookmarkId, String newName) async {
    final bookmark = _databaseService.getBookmark(bookmarkId);
    if (bookmark != null) {
      bookmark.name = newName;
      await _databaseService.updateBookmark(bookmark);
    }
  }

  /// Delete bookmark
  Future<void> deleteBookmark(String bookmarkId) async {
    await _databaseService.deleteBookmark(bookmarkId);
  }

  /// Get all bookmarks
  List<BookmarkModel> getAllBookmarks() {
    return _databaseService.getAllBookmarks();
  }
}
