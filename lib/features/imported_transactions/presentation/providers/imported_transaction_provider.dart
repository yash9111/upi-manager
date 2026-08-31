import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/core/services/notification_service.dart';
import 'package:upi_tracker/features/imported_transactions/data/services/incoming_sms_bootstrap_service.dart';
import 'package:upi_tracker/features/imported_transactions/data/services/incoming_sms_service.dart';
import 'package:upi_tracker/features/imported_transactions/data/services/sms_permission_service.dart';
import 'package:upi_tracker/features/imported_transactions/presentation/services/incoming_sms_lifecycle_service.dart';

import '../../data/repositories/imported_transaction_repository.dart';
import '../../data/services/android_sms_reader_service.dart';
import '../../data/services/imported_transaction_batch_service.dart';
import '../../data/services/sms_reader_service.dart';
import '../../data/services/transaction_sms_parser_service.dart';
import '../../domain/models/imported_transaction.dart';

final smsReaderServiceProvider = Provider<SmsReaderService>((ref) {
  return AndroidSmsReaderService();
});

final incomingSmsLifecycleServiceProvider =
    Provider<IncomingSmsLifecycleService>((ref) {
      final service = IncomingSmsLifecycleService(ref);

      service.start();

      ref.onDispose(service.dispose);

      return service;
    });

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
final importedTransactionRepositoryProvider =
    Provider<ImportedTransactionRepository>((ref) {
      return ImportedTransactionRepository();
    });

final transactionSmsParserServiceProvider =
    Provider<TransactionSmsParserService>((ref) {
      return const TransactionSmsParserService();
    });

final importedTransactionBatchServiceProvider =
    Provider<ImportedTransactionBatchService>((ref) {
      return ImportedTransactionBatchService(
        smsReader: ref.read(smsReaderServiceProvider),
        parser: ref.read(transactionSmsParserServiceProvider),
        repository: ref.read(importedTransactionRepositoryProvider),
      );
    });

final importedTransactionsProvider =
    AsyncNotifierProvider<
      ImportedTransactionsNotifier,
      List<ImportedTransaction>
    >(ImportedTransactionsNotifier.new);
final smsPermissionServiceProvider = Provider<SmsPermissionService>((ref) {
  return SmsPermissionService();
});
final incomingSmsServiceProvider = Provider<IncomingSmsService>((ref) {
  return IncomingSmsService(
    parser: ref.read(transactionSmsParserServiceProvider),
    repository: ref.read(importedTransactionRepositoryProvider),
    notificationService: ref.read(notificationServiceProvider),
  );
});
final incomingSmsBootstrapServiceProvider =
    Provider<IncomingSmsBootstrapService>((ref) {
      return IncomingSmsBootstrapService(
        incomingSmsService: ref.read(incomingSmsServiceProvider),
      );
    });

class ImportedTransactionsNotifier
    extends AsyncNotifier<List<ImportedTransaction>> {
  ImportedTransactionRepository get _repository {
    return ref.read(importedTransactionRepositoryProvider);
  }

  TransactionSmsParserService get _parser {
    return ref.read(transactionSmsParserServiceProvider);
  }

  @override
  Future<List<ImportedTransaction>> build() async {
    return _load();
  }

  Future<List<ImportedTransaction>> _load() async {
    final transactions = await _repository.getAll();

    transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    return transactions;
  }

  Future<bool> importSms({
    required String sender,
    required String sms,
    required DateTime smsDate,
  }) async {
    final transaction = _parser.parseSms(
      sender: sender,
      sms: sms,
      smsDate: smsDate,
    );

    if (transaction == null) {
      return false;
    }

    final exists = await _repository.exists(transaction.id);

    if (exists) {
      return false;
    }

    await _repository.save(transaction);

    state = AsyncData(await _load());

    return true;
  }

  Future<void> markAsProcessed(String id) async {
    final transaction = await _findById(id);

    if (transaction == null) {
      return;
    }

    await _repository.update(
      transaction.copyWith(status: ImportedTransactionStatus.processed),
    );

    state = AsyncData(await _load());
  }

  Future<void> markAsIgnored(String id) async {
    final transaction = await _findById(id);

    if (transaction == null) {
      return;
    }

    await _repository.update(
      transaction.copyWith(status: ImportedTransactionStatus.ignored),
    );

    state = AsyncData(await _load());
  }

  Future<void> markAsPending(String id) async {
    final transaction = await _findById(id);

    if (transaction == null) {
      return;
    }

    await _repository.update(
      transaction.copyWith(status: ImportedTransactionStatus.pending),
    );

    state = AsyncData(await _load());
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);

    state = AsyncData(await _load());
  }

  Future<ImportedTransaction?> _findById(String id) async {
    final transactions = await _repository.getAll();

    for (final transaction in transactions) {
      if (transaction.id == id) {
        return transaction;
      }
    }

    return null;
  }
}
