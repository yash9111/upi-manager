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

    // Process anything that arrived while the app
    // was closed/backgrounded.
    processPendingSms();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      processPendingSms();
    }
  }

  Future<void> processPendingSms() async {
    if (_processing) {
      return;
    }

    _processing = true;

    try {
      final service = ref.read(incomingSmsServiceProvider);

      final result = await service.processPendingSms();

      /*
     * IncomingSmsService writes directly to the repository/Hive.
     *
     * The ImportedTransactionsNotifier does not automatically
     * know that Hive changed, so refresh its state after
     * successful processing.
     */
      if (result.imported > 0) {
        ref.invalidate(importedTransactionsProvider);
      }
    } catch (_) {
      /*
     * Keep the app alive if SMS processing fails.
     *
     * Failed native queue items remain available for retry.
     */
    } finally {
      _processing = false;
    }
  }
}
