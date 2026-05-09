import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/utils/expense_grouping_utils.dart';
import '../providers/expense_provider.dart';
import '../widgets/date_section_header.dart';
import '../widgets/expense_tile.dart';

class ExpensesScreen
    extends ConsumerWidget {
  const ExpensesScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final expenses = ref.watch(
      expensesProvider,
    );

    final groupedExpenses =
        ExpenseGroupingUtils
            .groupExpensesByDate(
      expenses,
    );

    return Scaffold(
      body: SafeArea(
        child: expenses.isEmpty
            ? const Center(
                child: Text(
                  'No expenses yet',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),

                    sliver:
                        SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'All Expenses',
                            style:
                                TextStyle(
                              fontSize:
                                  32,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            '${expenses.length} total transactions',
                            style:
                                const TextStyle(
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),

                          const SizedBox(
                            height: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  ...groupedExpenses.entries
                      .map((entry) {
                    return SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      sliver:
                          SliverList(
                        delegate:
                            SliverChildListDelegate(
                          [
                            DateSectionHeader(
                              title:
                                  entry.key,
                            ),

                            ...entry.value
                                .map(
                              (
                                expense,
                              ) {
                                return ExpenseTile(
                                  expense:
                                      expense,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}