// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 2;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      pdfViewerPackage: fields[0] as String,
      theme: fields[1] as String,
      enableMalwareScan: fields[2] as bool,
      loadFullPdf: fields[3] as bool,
      ttsVoice: fields[4] as String?,
      ttsSpeed: fields[5] as double,
      ttsPitch: fields[6] as double,
      plausibleDeniabilityEnabled: fields[7] as bool,
      useDarkPdfBackground: fields[8] as bool,
      scrollPhysics: fields[9] as double,
      zoomPhysics: fields[10] as double,
      dontShowDefaultAppPrompt: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.pdfViewerPackage)
      ..writeByte(1)
      ..write(obj.theme)
      ..writeByte(2)
      ..write(obj.enableMalwareScan)
      ..writeByte(3)
      ..write(obj.loadFullPdf)
      ..writeByte(4)
      ..write(obj.ttsVoice)
      ..writeByte(5)
      ..write(obj.ttsSpeed)
      ..writeByte(6)
      ..write(obj.ttsPitch)
      ..writeByte(7)
      ..write(obj.plausibleDeniabilityEnabled)
      ..writeByte(8)
      ..write(obj.useDarkPdfBackground)
      ..writeByte(9)
      ..write(obj.scrollPhysics)
      ..writeByte(10)
      ..write(obj.zoomPhysics)
      ..writeByte(11)
      ..write(obj.dontShowDefaultAppPrompt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
