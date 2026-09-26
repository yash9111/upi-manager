import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/imported_transactions/domain/models/imported_transaction.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';
import 'features/imported_transactions/presentation/providers/imported_transaction_provider.dart';
import 'features/imported_transactions/presentation/screens/imported_transaction_review_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>();

class ExpenseTrackerApp extends ConsumerStatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  ConsumerState<ExpenseTrackerApp> createState() =>
      _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState
    extends ConsumerState<ExpenseTrackerApp> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotificationNavigation();
    });
  }

  Future<void> _initializeNotificationNavigation() async {
    final notificationService =
        ref.read(notificationServiceProvider);

    notificationService.setNotificationTapHandler(
      _openTransactionFromNotification,
    );

    final initialTransactionId =
        await notificationService.getInitialTransactionId();

    if (initialTransactionId != null &&
        initialTransactionId.isNotEmpty) {
      _openTransactionFromNotification(
        initialTransactionId,
      );
    }
  }

  Future<void> _openTransactionFromNotification(
    String transactionId,
  ) async {
    final context =
        appNavigatorKey.currentContext;

    if (context == null) {
      return;
    }

    final repository =
        ref.read(
          importedTransactionRepositoryProvider,
        );

    final transactions =
        await repository.getAll();

    ImportedTransaction? transaction;

    for (final item in transactions) {
      if (item.id == transactionId) {
        transaction = item;
        break;
      }
    }

    if (transaction == null) {
      return;
    }

    final navigator =
        appNavigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (_) =>
            ImportedTransactionReviewScreen(
          transaction: transaction!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}