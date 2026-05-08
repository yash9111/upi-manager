// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_participant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitParticipantModelAdapter extends TypeAdapter<SplitParticipantModel> {
  @override
  final int typeId = 1;

  @override
  SplitParticipantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitParticipantModel(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      isSettled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SplitParticipantModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.isSettled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitParticipantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
