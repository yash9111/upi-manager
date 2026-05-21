import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/budget/presentation/providers/budget_month_provider.dart';
import 'package:upi_tracker/features/budget/presentation/widgets/budget_month_selector.dart';
import 'package:upi_tracker/features/budget/presentation/widgets/budget_summary_card.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/add_budget_dialog.dart';
import '../widgets/budget_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);

    final expenses = ref.watch(expensesProvider);

    final selectedMonth = ref.watch(selectedBudgetMonthProvider);

    final filteredBudgets = budgets.where((budget) {
      return budget.month == selectedMonth.month &&
          budget.year == selectedMonth.year;
    }).toList();

    double totalBudget = 0;
    double totalSpent = 0;

    for (final budget in filteredBudgets) {
      final spent = expenses
          .where(
            (expense) =>
                expense.category == budget.category &&
                expense.createdAt.month == budget.month &&
                expense.createdAt.year == budget.year,
          )
          .fold<double>(0, (sum, expense) => sum + expense.myShare);

      totalBudget += budget.amount;
      totalSpent += spent;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return const AddBudgetDialog();
            },
          );
        },
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget Mode',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text('Track spending against monthly goals'),

                    const SizedBox(height: 20),

                    BudgetSummaryCard(
                      totalBudget: totalBudget,
                      totalSpent: totalSpent,
                    ),

                    const SizedBox(height: 20),

                    const BudgetMonthSelector(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            filteredBudgets.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.savings_outlined,
                              size: 54,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            'No Budgets Yet',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Create category-wise budgets\nand track spending smarter',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: filteredBudgets.length,
                      itemBuilder: (context, index) {
                        final budget = filteredBudgets[index];

                        final spent = expenses
                            .where(
                              (expense) =>
                                  expense.category == budget.category &&
                                  expense.createdAt.month == budget.month &&
                                  expense.createdAt.year == budget.year,
                            )
                            .fold<double>(
                              0,
                              (sum, expense) => sum + expense.myShare,
                            );

                        return BudgetCard(
                          category: budget.category,
                          spent: spent,
                          total: budget.amount,

                          onEdit: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AddBudgetDialog(
                                  initialCategory: budget.category,
                                  initialAmount: budget.amount,
                                  initialMonth: DateTime(
                                    budget.year,
                                    budget.month,
                                  ),
                                );
                              },
                            );
                          },

                          onDelete: () async {
                            await ref
                                .read(budgetsProvider.notifier)
                                .deleteBudget(budget.id);
                          },
                        );
                      },
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}
