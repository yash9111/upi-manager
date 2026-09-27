import 'package:upi_tracker/core/services/notification_service.dart';

import '../../domain/models/imported_transaction.dart';
import '../services/gpay_split_parser_service.dart';
import '../repositories/imported_transaction_repository.dart';

class GPaySplitImportService {
  final NotificationService notificationService;
  final GPaySplitParserService parser;
  final ImportedTransactionRepository repository;

  GPaySplitImportService({
    required this.notificationService,
    required this.parser,
    required this.repository,
  });

  Future<int> processPendingNotifications() async {
    final notifications = await notificationService
        .getPendingGPayNotifications();

    var importedCount = 0;

    for (final notification in notifications) {
      final id = notification['id']?.toString();

      if (id == null || id.isEmpty) {
        continue;
      }

      try {
        final alreadyExists = await repository.exists(id);

        if (alreadyExists) {
          await notificationService.acknowledgeGPayNotification(id);
          continue;
        }

        final title = notification['title']?.toString() ?? '';

        final text = notification['text']?.toString() ?? '';

        final bigText = notification['bigText']?.toString() ?? '';

        final timestampValue = notification['timestamp'];

        final timestamp = timestampValue is int
            ? DateTime.fromMillisecondsSinceEpoch(timestampValue)
            : DateTime.now();

        final transaction = parser.parse(
          id: id,
          title: title,
          text: text,
          bigText: bigText,
          timestamp: timestamp,
        );

        if (transaction == null) {
          // Invalid/non-parseable GPay notification.
          // Remove it from the native queue so it
          // doesn't get processed repeatedly.
          await notificationService.acknowledgeGPayNotification(id);

          continue;
        }

        await repository.save(transaction);

        // IMPORTANT:
        // Only acknowledge AFTER successful Hive save.
        final acknowledged = await notificationService
            .acknowledgeGPayNotification(id);

        if (acknowledged) {
          importedCount++;
        }
      } catch (_) {
        // Do NOT acknowledge.
        //
        // The notification remains in the native queue
        // and can be retried later.
      }
    }

    return importedCount;
  }
}
