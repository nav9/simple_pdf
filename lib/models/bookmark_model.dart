import 'package:hive/hive.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 1)
class BookmarkModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String pdfId;

  @HiveField(2)
  String name;

  @HiveField(3)
  int pageNumber;

  @HiveField(4)
  DateTime dateCreated;

  BookmarkModel({
    required this.id,
    required this.pdfId,
    required this.name,
    required this.pageNumber,
    required this.dateCreated,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'pdfId': pdfId,
        'name': name,
        'pageNumber': pageNumber,
        'dateCreated': dateCreated.toIso8601String(),
      };

  factory BookmarkModel.fromJson(Map<String, dynamic> json) => BookmarkModel(
        id: json['id'],
        pdfId: json['pdfId'],
        name: json['name'],
        pageNumber: json['pageNumber'],
        dateCreated: DateTime.parse(json['dateCreated']),
      );
}
