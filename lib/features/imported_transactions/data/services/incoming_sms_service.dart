import 'package:flutter/services.dart';
import 'package:upi_tracker/core/services/notification_service.dart';

import '../../domain/models/imported_transaction.dart';
import '../repositories/imported_transaction_repository.dart';
import 'transaction_sms_parser_service.dart';

class IncomingSmsService {
  static const MethodChannel _channel = MethodChannel(
    'upi_tracker/incoming_sms',
  );

  final TransactionSmsParserService parser;
  final ImportedTransactionRepository repository;
  final NotificationService notificationService;
  const IncomingSmsService({
    required this.parser,
    required this.repository,
    required this.notificationService,
  });

  Future<IncomingSmsImportResult> processPendingSms() async {
    final pendingSms = await _getPendingSms();

    if (pendingSms.isEmpty) {
      return const IncomingSmsImportResult();
    }

    int parsed = 0;
    int imported = 0;
    int duplicates = 0;
    int failed = 0;

    for (final sms in pendingSms) {
      final nativeId = sms['id'] as String?;

      if (nativeId == null || nativeId.isEmpty) {
        failed++;
        continue;
      }

      try {
        final sender = sms['sender'] as String? ?? '';
        final body = sms['body'] as String? ?? '';
        final timestamp = sms['timestamp'];

        if (body.trim().isEmpty) {
          failed++;
          continue;
        }

        final transaction = parser.parseSms(
          sender: sender,
          sms: body,
          smsDate: _parseTimestamp(timestamp),
        );

        /*
         * A non-transaction SMS is a successful processing
         * outcome. We do not want it retried forever.
         */
        if (transaction == null) {
          await _acknowledgeSms(nativeId);
          continue;
        }

        parsed++;

        final exists = await repository.exists(transaction.id);

        if (exists) {
          duplicates++;

          await _acknowledgeSms(nativeId);
          continue;
        }

        await repository.save(transaction);

        imported++;

        await notificationService.showTransactionNotification(
          notificationId: transaction.id.hashCode,
          title: transaction.type == ImportedTransactionType.debit
              ? 'New expense detected'
              : 'Money received',
          body: _buildNotificationBody(transaction),
          transactionId: transaction.id,
        );

        /*
         * Acknowledge only AFTER Hive save succeeds.
         */
        await _acknowledgeSms(nativeId);
      } catch (_) {
        /*
         * Keep the native SMS in the queue.
         *
         * It can be retried on the next processing attempt.
         */
        failed++;
      }
    }

    return IncomingSmsImportResult(
      totalSms: pendingSms.length,
      parsed: parsed,
      imported: imported,
      duplicates: duplicates,
      failed: failed,
    );
  }

  String _buildNotificationBody(ImportedTransaction transaction) {
    final amount = '₹${transaction.amount.toStringAsFixed(2)}';

    final merchant = transaction.merchant?.trim();

    if (merchant != null && merchant.isNotEmpty) {
      return '$amount • $merchant';
    }

    if (transaction.bankName?.trim().isNotEmpty ?? false) {
      return '$amount • ${transaction.bankName}';
    }

    return amount;
  }

  Future<List<Map<String, dynamic>>> _getPendingSms() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getPendingSms');

    if (result == null) {
      return const [];
    }

    return result
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<bool> _acknowledgeSms(String id) async {
    final result = await _channel.invokeMethod<bool>('acknowledgeSms', {
      'id': id,
    });

    return result ?? false;
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    if (timestamp is num) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    }

    return DateTime.now();
  }
}

class IncomingSmsImportResult {
  final int totalSms;
  final int parsed;
  final int imported;
  final int duplicates;
  final int failed;

  const IncomingSmsImportResult({
    this.totalSms = 0,
    this.parsed = 0,
    this.imported = 0,
    this.duplicates = 0,
    this.failed = 0,
  });
  @override
  String toString() {
    return 'IncomingSmsImportResult(totalSms: $totalSms, parsed: $parsed, imported: $imported, duplicates: $duplicates, failed: $failed)';
  }
}
