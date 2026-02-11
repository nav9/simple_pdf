// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfFileModelAdapter extends TypeAdapter<PdfFileModel> {
  @override
  final int typeId = 0;

  @override
  PdfFileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfFileModel(
      id: fields[0] as String,
      name: fields[1] as String,
      filePath: fields[2] as String,
      dateAdded: fields[3] as DateTime,
      dateModified: fields[4] as DateTime,
      fileSize: fields[5] as int,
      isEncrypted: fields[6] as bool,
      encryptionKey: fields[7] as String?,
      pageCount: fields[8] as int,
      thumbnailPath: fields[9] as String?,
      isInTrash: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PdfFileModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.dateAdded)
      ..writeByte(4)
      ..write(obj.dateModified)
      ..writeByte(5)
      ..write(obj.fileSize)
      ..writeByte(6)
      ..write(obj.isEncrypted)
      ..writeByte(7)
      ..write(obj.encryptionKey)
      ..writeByte(8)
      ..write(obj.pageCount)
      ..writeByte(9)
      ..write(obj.thumbnailPath)
      ..writeByte(10)
      ..write(obj.isInTrash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfFileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
