import '../../domain/models/imported_transaction.dart';

class FallbackTransactionParser {
  const FallbackTransactionParser();

  ImportedTransaction?
      parse({
    required String sms,
  required DateTime smsDate,
  required String sender,
  required ImportedTransactionType expectedType,
  }) {
    final normalized =
        sms.replaceAll(
      RegExp(r'\s+'),
      ' ',
    ).trim();

    if (normalized.isEmpty) {
      return null;
    }

    final type =
        _detectType(normalized);

    if (type ==
        ImportedTransactionType
            .unknown) {
      return null;
    }

    final amount =
        _extractAmount(normalized);

    if (amount == null ||
        amount <= 0) {
      return null;
    }

    final reference =
        _extractReference(
      normalized,
    );

    final upiId =
        _extractUpiId(normalized);

    final merchant =
        _extractMerchant(
      normalized,
      upiId,
    );

    final bank =
        _extractBank(normalized);

    final id =
        _createId(
      sms: normalized,
      reference: reference,
      amount: amount,
      date: smsDate,
    );

    return ImportedTransaction(
      id: id,
      amount: amount,
      type: type,
      merchant: merchant,
      upiId: upiId,
      referenceNumber: reference,
      bankName: bank,
      transactionDate: smsDate,
      importedAt: DateTime.now(),
      rawSms: sms,
    );
  }

  ImportedTransactionType
      _detectType(String sms) {
    final text =
        sms.toLowerCase();

    final creditWords = [
      'credited',
      'credit',
      'received',
      'deposited',
      'deposit',
      'refund',
      'cashback',
    ];

    final debitWords = [
      'debited',
      'debit',
      'paid',
      'payment',
      'spent',
      'purchase',
      'withdrawn',
      'withdrawal',
      'transferred',
      'transfer',
      'sent',
      'deducted',
    ];

    final hasCredit =
        creditWords.any(
      text.contains,
    );

    final hasDebit =
        debitWords.any(
      text.contains,
    );

    if (hasDebit && !hasCredit) {
      return ImportedTransactionType
          .debit;
    }

    if (hasCredit && !hasDebit) {
      return ImportedTransactionType
          .credit;
    }

    return ImportedTransactionType
        .unknown;
  }

  double? _extractAmount(
    String sms,
  ) {
    final patterns = [
      RegExp(
        r'(?:rs\.?|inr|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
        caseSensitive: false,
      ),

      RegExp(
        r'(?:rs\.?|inr|₹)\s*([0-9,]+)',
        caseSensitive: false,
      ),

      RegExp(
        r'(?:amount|amt)\s*(?:is|:)?\s*(?:rs\.?|inr|₹)?\s*([0-9,]+(?:\.[0-9]{1,2})?)',
        caseSensitive: false,
      ),
    ];

    for (final pattern
        in patterns) {
      final match =
          pattern.firstMatch(sms);

      if (match == null) {
        continue;
      }

      final value =
          match.group(1);

      if (value == null) {
        continue;
      }

      final amount =
          double.tryParse(
        value.replaceAll(
          ',',
          '',
        ),
      );

      if (amount != null) {
        return amount;
      }
    }

    return null;
  }

  String? _extractReference(
    String sms,
  ) {
    final patterns = [
      RegExp(
        r'(?:upi\s*)?(?:ref(?:erence)?|txn|transaction)\s*(?:no|number|id)?\s*[:#-]?\s*([0-9]{6,})',
        caseSensitive: false,
      ),

      RegExp(
        r'\bRRN\b\s*[:#-]?\s*([0-9]{6,})',
        caseSensitive: false,
      ),
    ];

    for (final pattern
        in patterns) {
      final match =
          pattern.firstMatch(sms);

      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  String? _extractUpiId(
    String sms,
  ) {
    final match =
        RegExp(
      r'\b[\w.\-]+@[\w.\-]+\b',
      caseSensitive: false,
    ).firstMatch(sms);

    return match?.group(0);
  }

  String? _extractMerchant(
    String sms,
    String? upiId,
  ) {
    if (upiId != null) {
      final beforeUpi =
          sms.substring(
        0,
        sms.indexOf(
          upiId,
        ),
      );

      final patterns = [
        RegExp(
          r'(?:to|paid to|sent to|for)\s+(.+?)\s*(?:via\s+upi|upi)?$',
          caseSensitive: false,
        ),

        RegExp(
          r'(?:to|paid to|sent to|for)\s+(.+?)\s*$',
          caseSensitive: false,
        ),
      ];

      for (final pattern
          in patterns) {
        final match =
            pattern.firstMatch(
          beforeUpi,
        );

        if (match != null) {
          final value =
              match.group(1)?.trim();

          if (value != null &&
              value.isNotEmpty) {
            return value;
          }
        }
      }
    }

    final patterns = [
      RegExp(
        r'(?:paid to|sent to|payment to|trf to)\s+([A-Za-z0-9 &._-]+)',
        caseSensitive: false,
      ),

      RegExp(
        r'(?:merchant|shop)\s*[:\-]?\s*([A-Za-z0-9 &._-]+)',
        caseSensitive: false,
      ),
    ];

    for (final pattern
        in patterns) {
      final match =
          pattern.firstMatch(sms);

      if (match != null) {
        return match
            .group(1)
            ?.trim();
      }
    }

    return null;
  }

  String? _extractBank(
    String sms,
  ) {
    const banks = [
      'HDFC',
      'ICICI',
      'SBI',
      'AXIS',
      'KOTAK',
      'PNB',
      'BOB',
      'BANK OF BARODA',
      'IDFC',
      'YES BANK',
      'INDUSIND',
      'FEDERAL BANK',
      'CANARA',
      'UNION BANK',
      'IDBI',
      'RBL',
      'HSBC',
    ];

    final upper =
        sms.toUpperCase();

    for (final bank in banks) {
      if (upper.contains(bank)) {
        return bank;
      }
    }

    return null;
  }

  String _createId({
    required String sms,
    required String? reference,
    required double amount,
    required DateTime date,
  }) {
    if (reference != null &&
        reference.isNotEmpty) {
      return 'upi_$reference';
    }

    return 'sms_${date.millisecondsSinceEpoch}_${amount.toStringAsFixed(2)}_${sms.hashCode}';
  }
}