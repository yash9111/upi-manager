import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/imported_transactions/presentation/providers/imported_transaction_provider.dart';

import '../../data/services/incoming_sms_service.dart';

class IncomingSmsLifecycleService with WidgetsBindingObserver {
  final Ref ref;

  bool _processing = false;

  IncomingSmsLifecycleService(this.ref);

  void start() {
    WidgetsBinding.instance.addObserver(this);

    processPending();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      processPending();
    }
  }

  Future<void> processPending() async {
    if (_processing) {
      return;
    }

    _processing = true;

    try {
      // 1. Process SMS queue.
      final smsService = ref.read(incomingSmsServiceProvider);

      final smsResult = await smsService.processPendingSms();

      // 2. Process GPay queue.
      final gPayService = ref.read(gPaySplitImportServiceProvider);

      final gPayImported = await gPayService.processPendingNotifications();

      // 3. Refresh UI if anything was imported.
      if (smsResult.imported > 0 || gPayImported > 0) {
        ref.invalidate(importedTransactionsProvider);
      }
    } catch (_) {
      // Keep the app alive.
      //
      // Failed GPay/SMS items remain available
      // for retry.
    } finally {
      _processing = false;
    }
  }
}
