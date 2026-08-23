import 'dart:developer' as developer;

import 'package:transaction_sms_parser/transaction_sms_parser.dart';

import '../../domain/models/imported_transaction.dart';
import '../../domain/models/bank_sms_config.dart';
import '../config/trusted_bank_sms_config.dart';
import 'fallback_transaction_parser.dart';

import 'package:transaction_sms_parser/transaction_sms_parser.dart';

import '../../domain/models/imported_transaction.dart';
import 'fallback_transaction_parser.dart';
import 'transaction_sms_classifier.dart';

class TransactionSmsParserService {
  final FallbackTransactionParser _fallbackParser;
  final TransactionSmsClassifier _classifier;

  const TransactionSmsParserService({
    FallbackTransactionParser? fallbackParser,
    TransactionSmsClassifier? classifier,
  })  : _fallbackParser =
            fallbackParser ?? const FallbackTransactionParser(),
        _classifier =
            classifier ?? const TransactionSmsClassifier();

  ImportedTransaction? parseSms({
    required String sms,
    required DateTime smsDate,
    required String sender,
  }) {
    // ------------------------------------------------------------
    // STEP 1
    // Trusted sender validation
    // ------------------------------------------------------------

    if (!_isTrustedSender(sender)) {
      return null;
    }

    // ------------------------------------------------------------
    // STEP 2
    // Our own transaction classification
    // ------------------------------------------------------------

    final classification = _classifier.classify(sms);

    if (classification ==
        SmsTransactionClassification.promotional) {
      return null;
    }

    // if (classification ==
    //     SmsTransactionClassification.nonTransaction) {
    //   return null;
    // }

    if (classification ==
        SmsTransactionClassification.unknown) {
      return null;
    }

    // ------------------------------------------------------------
    // STEP 3
    // Package parser
    // ------------------------------------------------------------

    final packageResult = _parseUsingPackage(
      sms: sms,
      smsDate: smsDate,
      classification: classification,
    );

    if (packageResult != null) {
      return packageResult;
    }

    // ------------------------------------------------------------
    // STEP 4
    // Fallback parser
    // ------------------------------------------------------------

    return _fallbackParser.parse(
      sms: sms,
      smsDate: smsDate,
      sender: sender,
      expectedType: _mapClassification(
        classification,
      ),
    );
  }

  ImportedTransaction? _parseUsingPackage({
    required String sms,
    required DateTime smsDate,
    required SmsTransactionClassification classification,
  }) {
    try {
      final result =
          TransactionEngine.getTransactionInfo(sms);

      final amountString =
          result.transaction.amount;

      final amount = double.tryParse(
        amountString
                ?.replaceAll(',', '')
                .trim() ??
            '',
      );

      if (amount == null || amount <= 0) {
        return null;
      }

      // IMPORTANT:
      //
      // We don't blindly trust the package type.
      // Our classifier has already determined the
      // direction of the transaction.

      final type = _mapClassification(
        classification,
      );

      final reference =
          result.transaction.referenceNo;

      final id = reference != null &&
              reference.trim().isNotEmpty
          ? 'upi_${reference.trim()}'
          : 'sms_${smsDate.millisecondsSinceEpoch}_${amount.toStringAsFixed(2)}_${sms.hashCode}';

      final balance = double.tryParse(
        result.balance?.available
                ?.replaceAll(',', '')
                .trim() ??
            '',
      );

      return ImportedTransaction(
        id: id,
        amount: amount,
        type: type,
        merchant:
            result.transaction.merchant,
        upiId: result.account.name,
        referenceNumber: reference,
        bankName:
            result.account.bankName,
        accountNumber:
            result.account.number,
        availableBalance: balance,
        transactionDate: smsDate,
        importedAt: DateTime.now(),
        rawSms: sms,
      );
    } catch (_) {
      return null;
    }
  }

  ImportedTransactionType _mapClassification(
    SmsTransactionClassification classification,
  ) {
    switch (classification) {
      case SmsTransactionClassification.debit:
        return ImportedTransactionType.debit;

      case SmsTransactionClassification.credit:
        return ImportedTransactionType.credit;

      default:
        return ImportedTransactionType.unknown;
    }
  }

  bool _isTrustedSender(String sender) {
    // KEEP YOUR EXISTING IMPLEMENTATION HERE.
    //
    // We don't want to change your existing
    // bank sender configuration in this step.
    return true;
  }
}