// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_request_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PickupRequestModelAdapter extends TypeAdapter<PickupRequestModel> {
  @override
  final int typeId = 2;

  @override
  PickupRequestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PickupRequestModel(
      id: fields[0] as String,
      scheduledDate: fields[1] as DateTime,
      address: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      status: fields[5] as String,
      userId: fields[6] as String,
      wasteLogId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PickupRequestModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scheduledDate)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.wasteLogId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickupRequestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
