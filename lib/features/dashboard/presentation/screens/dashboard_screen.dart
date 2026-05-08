import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/expenses/domain/expense_filter_utils.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../expenses/domain/enums/expense_category_filter.dart';
import '../../../expenses/domain/enums/expense_filter_type.dart';
import '../../../expenses/presentation/providers/expense_filter_provider.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../expenses/presentation/screens/add_expense_screen.dart';
import '../../../expenses/presentation/widgets/expense_tile.dart';
import '../../../expenses/presentation/widgets/filter_chip_item.dart';
import '../../domain/utils/dashboard_analytics_utils.dart';

class DashboardScreen
    extends ConsumerWidget {
  const DashboardScreen({
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

    final selectedTimeFilter =
        ref.watch(
      expenseTimeFilterProvider,
    );

    final selectedCategoryFilter =
        ref.watch(
      expenseCategoryFilterProvider,
    );

    final filteredExpenses =
        ExpenseFilterUtils
            .filterExpenses(
      expenses: expenses,
      timeFilter:
          selectedTimeFilter,
      categoryFilter:
          selectedCategoryFilter,
    );

    final totalSpend =
        DashboardAnalyticsUtils
            .calculateTotalSpend(
      filteredExpenses,
    );

    final monthlySpend =
        DashboardAnalyticsUtils
            .calculateMonthlySpend(
      filteredExpenses,
    );

    return Scaffold(
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddExpenseScreen(),
            ),
          );
        },
        child:
            const Icon(Icons.add),
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding:
                  const EdgeInsets.all(
                20,
              ),

              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Expenses',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // COMPACT SUMMARY CARD

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.all(
                        22,
                      ),
                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            AppColors
                                .primary,
                            AppColors
                                .secondary,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          26,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Text(
                                'Total Spend',
                                style:
                                    TextStyle(
                                  color: Colors
                                      .white70,
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(
                                '₹${totalSpend.toStringAsFixed(0)}',
                                style:
                                    const TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize:
                                      30,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .end,
                            children: [
                              const Text(
                                'Monthly',
                                style:
                                    TextStyle(
                                  color: Colors
                                      .white70,
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(
                                '₹${monthlySpend.toStringAsFixed(0)}',
                                style:
                                    const TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize:
                                      22,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // TIME FILTERS

                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection:
                            Axis.horizontal,
                        children: [
                          buildTimeChip(
                            ref,
                            'All',
                            ExpenseFilterType
                                .all,
                            selectedTimeFilter,
                          ),

                          buildTimeChip(
                            ref,
                            'Today',
                            ExpenseFilterType
                                .today,
                            selectedTimeFilter,
                          ),

                          buildTimeChip(
                            ref,
                            'Weekly',
                            ExpenseFilterType
                                .weekly,
                            selectedTimeFilter,
                          ),

                          buildTimeChip(
                            ref,
                            'Monthly',
                            ExpenseFilterType
                                .monthly,
                            selectedTimeFilter,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // CATEGORY FILTERS

                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection:
                            Axis.horizontal,
                        children: [
                          buildCategoryChip(
                            ref,
                            'All',
                            ExpenseCategoryFilter
                                .all,
                            selectedCategoryFilter,
                          ),

                          buildCategoryChip(
                            ref,
                            'Food',
                            ExpenseCategoryFilter
                                .food,
                            selectedCategoryFilter,
                          ),

                          buildCategoryChip(
                            ref,
                            'Travel',
                            ExpenseCategoryFilter
                                .travel,
                            selectedCategoryFilter,
                          ),

                          buildCategoryChip(
                            ref,
                            'Shopping',
                            ExpenseCategoryFilter
                                .shopping,
                            selectedCategoryFilter,
                          ),

                          buildCategoryChip(
                            ref,
                            'Bills',
                            ExpenseCategoryFilter
                                .bills,
                            selectedCategoryFilter,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        Text(
                          '${filteredExpenses.length} items',
                          style:
                              const TextStyle(
                            color: AppColors
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // RECENT EXPENSES

            filteredExpenses.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No expenses found',
                      ),
                    ),
                  )
                : SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    sliver:
                        SliverList.builder(
                      itemCount:
                          filteredExpenses
                              .length,
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        return ExpenseTile(
                          expense:
                              filteredExpenses[
                                  index],
                        );
                      },
                    ),
                  ),

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

  Widget buildTimeChip(
    WidgetRef ref,
    String label,
    ExpenseFilterType filter,
    ExpenseFilterType selected,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 10,
      ),
      child: FilterChipItem(
        label: label,
        selected:
            selected == filter,
        onTap: () {
          ref
              .read(
                expenseTimeFilterProvider
                    .notifier,
              )
              .state = filter;
        },
      ),
    );
  }

  Widget buildCategoryChip(
    WidgetRef ref,
    String label,
    ExpenseCategoryFilter
        category,
    ExpenseCategoryFilter
        selected,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 10,
      ),
      child: FilterChipItem(
        label: label,
        selected:
            selected ==
                category,
        onTap: () {
          ref
              .read(
                expenseCategoryFilterProvider
                    .notifier,
              )
              .state = category;
        },
      ),
    );
  }
}