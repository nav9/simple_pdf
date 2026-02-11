import 'package:hive/hive.dart';

part 'pdf_file_model.g.dart';

@HiveType(typeId: 0)
class PdfFileModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  DateTime dateAdded;

  @HiveField(4)
  DateTime dateModified;

  @HiveField(5)
  int fileSize;

  @HiveField(6)
  bool isEncrypted;

  @HiveField(7)
  String? encryptionKey;

  @HiveField(8)
  int pageCount;

  @HiveField(9)
  String? thumbnailPath;

  @HiveField(10)
  bool isInTrash;

  PdfFileModel({
    required this.id,
    required this.name,
    required this.filePath,
    required this.dateAdded,
    required this.dateModified,
    required this.fileSize,
    this.isEncrypted = false,
    this.encryptionKey,
    this.pageCount = 0,
    this.thumbnailPath,
    this.isInTrash = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'filePath': filePath,
        'dateAdded': dateAdded.toIso8601String(),
        'dateModified': dateModified.toIso8601String(),
        'fileSize': fileSize,
        'isEncrypted': isEncrypted,
        'encryptionKey': encryptionKey,
        'pageCount': pageCount,
        'thumbnailPath': thumbnailPath,
        'isInTrash': isInTrash,
      };

  factory PdfFileModel.fromJson(Map<String, dynamic> json) => PdfFileModel(
        id: json['id'],
        name: json['name'],
        filePath: json['filePath'],
        dateAdded: DateTime.parse(json['dateAdded']),
        dateModified: DateTime.parse(json['dateModified']),
        fileSize: json['fileSize'],
        isEncrypted: json['isEncrypted'] ?? false,
        encryptionKey: json['encryptionKey'],
        pageCount: json['pageCount'] ?? 0,
        thumbnailPath: json['thumbnailPath'],
        isInTrash: json['isInTrash'] ?? false,
      );
}
