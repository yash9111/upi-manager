import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';

class ExpenseTrackerApp
    extends StatelessWidget {
  const ExpenseTrackerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner:
            false,
        title: 'Expense Tracker',
        theme: AppTheme.lightTheme,
        home: const MainShell(),
      ),
    );
  }
}