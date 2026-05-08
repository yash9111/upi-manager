import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_tile.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final expenses = ref.watch(
      expensesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: expenses.isEmpty
          ? const Center(
              child: Text(
                'No expenses yet',
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(20),
              itemCount: expenses.length,
              itemBuilder: (
                context,
                index,
              ) {
                final ExpenseModel expense =
                    expenses.reversed
                        .toList()[index];

                return ExpenseTile(
                  expense: expense,
                );
              },
            ),
    );
  }
}