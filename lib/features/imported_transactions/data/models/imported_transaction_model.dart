import 'package:hive/hive.dart';

import '../../domain/models/imported_transaction.dart';

part 'imported_transaction_model.g.dart';

@HiveType(typeId: 10)
class ImportedTransactionModel
    extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String? merchant;

  @HiveField(4)
  final String? upiId;

  @HiveField(5)
  final String? referenceNumber;

  @HiveField(6)
  final String? bankName;

  @HiveField(7)
  final String? accountNumber;

  @HiveField(8)
  final double? availableBalance;

  @HiveField(9)
  final DateTime transactionDate;

  @HiveField(10)
  final DateTime importedAt;

  @HiveField(11)
  final String rawSms;

  @HiveField(12)
  final String status;

  ImportedTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    this.merchant,
    this.upiId,
    this.referenceNumber,
    this.bankName,
    this.accountNumber,
    this.availableBalance,
    required this.transactionDate,
    required this.importedAt,
    required this.rawSms,
    required this.status,
  });

  factory ImportedTransactionModel.fromDomain(
    ImportedTransaction transaction,
  ) {
    return ImportedTransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      type: transaction.type.name,
      merchant: transaction.merchant,
      upiId: transaction.upiId,
      referenceNumber:
          transaction.referenceNumber,
      bankName:
          transaction.bankName,
      accountNumber:
          transaction.accountNumber,
      availableBalance:
          transaction.availableBalance,
      transactionDate:
          transaction.transactionDate,
      importedAt:
          transaction.importedAt,
      rawSms:
          transaction.rawSms,
      status:
          transaction.status.name,
    );
  }

  ImportedTransaction toDomain() {
    return ImportedTransaction(
      id: id,
      amount: amount,
      type:
          ImportedTransactionType
              .values
              .firstWhere(
        (value) =>
            value.name == type,
        orElse: () =>
            ImportedTransactionType
                .unknown,
      ),
      merchant: merchant,
      upiId: upiId,
      referenceNumber:
          referenceNumber,
      bankName: bankName,
      accountNumber:
          accountNumber,
      availableBalance:
          availableBalance,
      transactionDate:
          transactionDate,
      importedAt: importedAt,
      rawSms: rawSms,
      status:
          ImportedTransactionStatus
              .values
              .firstWhere(
        (value) =>
            value.name == status,
        orElse: () =>
            ImportedTransactionStatus
                .pending,
      ),
    );
  }
}