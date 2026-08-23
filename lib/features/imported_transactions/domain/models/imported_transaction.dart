enum ImportedTransactionStatus {
  pending,
  processed,
  ignored,
}

enum ImportedTransactionType {
  debit,
  credit,
  unknown,
}

class ImportedTransaction {
  final String id;

  final double amount;

  final ImportedTransactionType type;

  final String? merchant;

  final String? upiId;

  final String? referenceNumber;

  final String? bankName;

  final String? accountNumber;

  final double? availableBalance;

  final DateTime transactionDate;

  final DateTime importedAt;

  final String rawSms;

  final ImportedTransactionStatus status;

  const ImportedTransaction({
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
    this.status =
        ImportedTransactionStatus.pending,
  });

  ImportedTransaction copyWith({
    String? id,
    double? amount,
    ImportedTransactionType? type,
    String? merchant,
    String? upiId,
    String? referenceNumber,
    String? bankName,
    String? accountNumber,
    double? availableBalance,
    DateTime? transactionDate,
    DateTime? importedAt,
    String? rawSms,
    ImportedTransactionStatus? status,
  }) {
    return ImportedTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      merchant:
          merchant ?? this.merchant,
      upiId: upiId ?? this.upiId,
      referenceNumber:
          referenceNumber ??
              this.referenceNumber,
      bankName:
          bankName ?? this.bankName,
      accountNumber:
          accountNumber ??
              this.accountNumber,
      availableBalance:
          availableBalance ??
              this.availableBalance,
      transactionDate:
          transactionDate ??
              this.transactionDate,
      importedAt:
          importedAt ?? this.importedAt,
      rawSms: rawSms ?? this.rawSms,
      status:
          status ?? this.status,
    );
  }
}