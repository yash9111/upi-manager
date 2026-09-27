import '../../domain/models/imported_transaction.dart';

class GPaySplitParserService {
  ImportedTransaction? parse({
    required String id,
    required String title,
    required String text,
    required String bigText,
    required DateTime timestamp,
  }) {
    final content = bigText.isNotEmpty ? bigText : text;

    final amountRegex = RegExp(r'₹\s*([\d,]+(?:\.\d{1,2})?)');

    final amountMatch = amountRegex.firstMatch(content);

    if (amountMatch == null) {
      return null;
    }

    final amountString = amountMatch.group(1)!.replaceAll(',', '');

    final amount = double.tryParse(amountString);

    if (amount == null || amount <= 0) {
      return null;
    }

    final personRegex = RegExp(r'^Pay\s+(.+?)\s+₹', caseSensitive: false);

    final personMatch = personRegex.firstMatch(content);

    final person = personMatch?.group(1)?.trim();

    final descriptionRegex = RegExp(
      r'\bfor\s+[‘“"](.+?)[’”"]',
      caseSensitive: false,
    );

    final descriptionMatch = descriptionRegex.firstMatch(content);

    final description = descriptionMatch?.group(1)?.trim();

    final groupRegex = RegExp(
      r'split request in\s+[‘“"](.+?)[’”"]',
      caseSensitive: false,
    );

    final groupMatch = groupRegex.firstMatch(title);

    final group = groupMatch?.group(1)?.trim();

    return ImportedTransaction(
      id: id,
      amount: amount,
      type: ImportedTransactionType.debit,
      merchant: person,
      transactionDate: timestamp,
      importedAt: DateTime.now(),
      rawSms: [
        title,
        text,
        bigText,
      ].where((value) => value.isNotEmpty).join('\n'),
      status: ImportedTransactionStatus.pending,
      source: ImportedTransactionSource.gpay,
      splitGroup: group,
      splitDescription: description,
    );
  }
}
