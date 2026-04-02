// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waste_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WasteLogModelAdapter extends TypeAdapter<WasteLogModel> {
  @override
  final int typeId = 1;

  @override
  WasteLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WasteLogModel(
      id: fields[0] as String,
      category: fields[1] as String,
      quantity: fields[2] as double,
      date: fields[3] as DateTime,
      isSynced: fields[4] as bool,
      imagePath: fields[5] as String?,
      userId: fields[6] as String,
      pickupStatus: fields[7] as String,
      location: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WasteLogModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.isSynced)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.pickupStatus)
      ..writeByte(8)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WasteLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
