import 'package:upi_tracker/features/imported_transactions/data/services/transaction_sms_classifier.dart';

class TransactionSmsExtractor {
  const TransactionSmsExtractor();

  double? extractAmount(
    String sms,
  ) {
    final patterns = [
      // Rs.60.00
      RegExp(
        r'\brs\.?\s*([\d,]+(?:\.\d+)?)',
        caseSensitive: false,
      ),

      // ₹60.00
      RegExp(
        r'₹\s*([\d,]+(?:\.\d+)?)',
        caseSensitive: false,
      ),

      // INR 60.00
      RegExp(
        r'\binr\s*([\d,]+(?:\.\d+)?)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final matches =
          pattern.allMatches(sms);

      for (final match in matches) {
        final value =
            double.tryParse(
          match.group(1)!
              .replaceAll(',', ''),
        );

        if (value != null) {
          return value;
        }
      }
    }

    return null;
  }

  String? extractReferenceNumber(
    String sms,
  ) {
    final match = RegExp(
      r'\bRRN\s*[:\-]?\s*(\d{6,})',
      caseSensitive: false,
    ).firstMatch(sms);

    return match?.group(1);
  }

  double? extractBalance(
    String sms,
  ) {
    final patterns = [
      RegExp(
        r'\bavl\s+bal(?:ance)?\s+rs\.?\s*([\d,]+(?:\.\d+)?)',
        caseSensitive: false,
      ),

      RegExp(
        r'\bavailable\s+balance\s+is\s+rs\.?\s*([\d,]+(?:\.\d+)?)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match =
          pattern.firstMatch(sms);

      if (match != null) {
        return double.tryParse(
          match
              .group(1)!
              .replaceAll(',', ''),
        );
      }
    }

    return null;
  }
  String? extractCounterparty(
  String sms,
  SmsTransactionClassification type,
) {
  if (type ==
      SmsTransactionClassification.debit) {
    final match = RegExp(
      r'\bto\s+(.+?)(?:\.RRN|\s+RRN|\s+Avl\s+Bal|\s+Not you)',
      caseSensitive: false,
    ).firstMatch(sms);

    return _cleanCounterparty(
      match?.group(1),
    );
  }

  if (type ==
      SmsTransactionClassification.credit) {
    final match = RegExp(
      r'\bby\s+(.+?)(?:\.?\s*RRN|\s+RRN|\.?\s+Available\s+balance)',
      caseSensitive: false,
    ).firstMatch(sms);

    return _cleanCounterparty(
      match?.group(1),
    );
  }

  return null;
}

String? _cleanCounterparty(
  String? value,
) {
  if (value == null) {
    return null;
  }

  final cleaned = value
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return cleaned.isEmpty
      ? null
      : cleaned;
}
}