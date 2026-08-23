// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imported_transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImportedTransactionModelAdapter
    extends TypeAdapter<ImportedTransactionModel> {
  @override
  final int typeId = 10;

  @override
  ImportedTransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImportedTransactionModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      type: fields[2] as String,
      merchant: fields[3] as String?,
      upiId: fields[4] as String?,
      referenceNumber: fields[5] as String?,
      bankName: fields[6] as String?,
      accountNumber: fields[7] as String?,
      availableBalance: fields[8] as double?,
      transactionDate: fields[9] as DateTime,
      importedAt: fields[10] as DateTime,
      rawSms: fields[11] as String,
      status: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ImportedTransactionModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.merchant)
      ..writeByte(4)
      ..write(obj.upiId)
      ..writeByte(5)
      ..write(obj.referenceNumber)
      ..writeByte(6)
      ..write(obj.bankName)
      ..writeByte(7)
      ..write(obj.accountNumber)
      ..writeByte(8)
      ..write(obj.availableBalance)
      ..writeByte(9)
      ..write(obj.transactionDate)
      ..writeByte(10)
      ..write(obj.importedAt)
      ..writeByte(11)
      ..write(obj.rawSms)
      ..writeByte(12)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportedTransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
