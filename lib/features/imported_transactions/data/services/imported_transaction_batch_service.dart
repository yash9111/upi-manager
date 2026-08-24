import '../../domain/models/imported_transaction.dart';
import '../repositories/imported_transaction_repository.dart';
import 'sms_reader_service.dart';
import 'transaction_sms_parser_service.dart';

class BatchImportResult {
  final int totalSms;
  final int candidateSms;
  final int parsed;
  final int imported;
  final int duplicates;
  final int failed;

  final int? packageParsed;
  final int? fallbackParsed;

  /// IDs of transactions that were actually imported
  /// during this specific batch operation.
  final List<String> importedTransactionIds;

  const BatchImportResult({
    required this.totalSms,
    required this.candidateSms,
    required this.parsed,
    required this.imported,
    required this.duplicates,
    required this.failed,
    required this.importedTransactionIds,
    this.packageParsed,
    this.fallbackParsed,
  });
}

class ImportedTransactionBatchService {
  final SmsReaderService smsReader;
  final TransactionSmsParserService parser;
  final ImportedTransactionRepository repository;

  const ImportedTransactionBatchService({
    required this.smsReader,
    required this.parser,
    required this.repository,
  });

  Future<BatchImportResult> importRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final messages = await smsReader.getMessages(
      startDate: startDate,
      endDate: endDate,
    );

    int candidateSms = 0;
    int parsed = 0;
    int imported = 0;
    int duplicates = 0;
    int failed = 0;

    final List<String> importedTransactionIds = [];

    for (final message in messages) {
      final transaction = parser.parseSms(
        sender: message.address ?? '',
        sms: message.body,
        smsDate: message.date,
      );

      if (transaction == null) {
        failed++;
        continue;
      }

      candidateSms++;
      parsed++;

      final exists = await repository.exists(transaction.id);

      if (exists) {
        duplicates++;
        continue;
      }

      await repository.save(transaction);

      imported++;
      importedTransactionIds.add(transaction.id);
    }

    return BatchImportResult(
      totalSms: messages.length,
      candidateSms: candidateSms,
      parsed: parsed,
      imported: imported,
      duplicates: duplicates,
      failed: failed,
      importedTransactionIds: importedTransactionIds,
    );
  }
}
