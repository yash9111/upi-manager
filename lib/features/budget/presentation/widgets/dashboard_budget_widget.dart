import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../domain/utils/budget_status_utils.dart';
import '../providers/budget_provider.dart';

class DashboardBudgetWidget extends ConsumerWidget {
  const DashboardBudgetWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);

    final expenses = ref.watch(expensesProvider);

    final now = DateTime.now();

    final currentMonthBudgets = budgets
        .where((budget) => budget.month == now.month && budget.year == now.year)
        .toList();

    if (currentMonthBudgets.isEmpty) {
      return const SizedBox();
    }

    final displayBudgets = currentMonthBudgets.take(3);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Budget Health',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'This Month',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...displayBudgets.map((budget) {
            final spent = expenses
                .where(
                  (expense) =>
                      expense.category == budget.category &&
                      expense.createdAt.month == budget.month &&
                      expense.createdAt.year == budget.year,
                )
                .fold<double>(0, (sum, expense) => sum + expense.myShare);

            final progress = budget.amount == 0
                ? 0.0
                : (spent / budget.amount).clamp(0, 1);

            final health = BudgetStatusUtils.getHealth(
              spent: spent,
              total: budget.amount,
            );

            final color = BudgetStatusUtils.color(health);

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          budget.category,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),

                      Text(
                        '₹${spent.toStringAsFixed(0)} / ₹${budget.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 9,
                      value: progress.toDouble(),
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }),

          if (currentMonthBudgets.length > 3)
            Center(
              child: Text(
                '+${currentMonthBudgets.length - 3} more budgets',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
