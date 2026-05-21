import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/budget/presentation/widgets/dashboard_budget_widget.dart';
import 'package:upi_tracker/features/category/presentation/providers/category_provider.dart';
import 'package:upi_tracker/features/dashboard/presentation/widgets/date_filter_section.dart';
import 'package:upi_tracker/features/dashboard/presentation/widgets/date_range_filter_section.dart';
import 'package:upi_tracker/features/expenses/domain/expense_filter_utils.dart';
import 'package:upi_tracker/features/expenses/presentation/providers/date_filter_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../expenses/domain/enums/expense_category_filter.dart';
import '../../../expenses/domain/enums/expense_filter_type.dart';
import '../../../expenses/presentation/providers/expense_filter_provider.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../expenses/presentation/screens/add_expense_screen.dart';
import '../../../expenses/presentation/widgets/expense_tile.dart';
import '../../../expenses/presentation/widgets/filter_chip_item.dart';
import '../../domain/utils/dashboard_analytics_utils.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);

    final selectedTimeFilter = ref.watch(expenseTimeFilterProvider);

    final selectedCategoryFilter = ref.watch(expenseCategoryFilterProvider);
    final selectedDateRange = ref.watch(selectedDateRangeProvider);
    final filteredExpenses = ExpenseFilterUtils.filterExpenses(
      expenses: expenses,
      timeFilter: selectedTimeFilter,
      categoryFilter: selectedCategoryFilter,
      selectedDateRange: selectedDateRange,
    );

    final totalSpend = DashboardAnalyticsUtils.calculateTotalSpend(
      filteredExpenses,
    );

    final monthlySpend = DashboardAnalyticsUtils.calculateMonthlySpend(
      filteredExpenses,
    );

    final weeklySpend = DashboardAnalyticsUtils.calculateWeeklySpend(
      filteredExpenses,
    );

    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
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
                      'Expenses',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // COMPACT SUMMARY CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Spend',
                                style: TextStyle(color: Colors.white70),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                '₹${totalSpend.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Monthly',
                                style: TextStyle(color: Colors.white70),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                '₹${monthlySpend.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // TIME FILTERS
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          buildTimeChip(
                            ref,
                            'All',
                            ExpenseFilterType.all,
                            selectedTimeFilter,
                          ),

                          buildTimeChip(
                            ref,
                            'Today',
                            ExpenseFilterType.today,
                            selectedTimeFilter,
                          ),

                          buildTimeChip(
                            ref,
                            'Weekly',
                            ExpenseFilterType.weekly,
                            selectedTimeFilter,
                          ),

                          buildTimeChip(
                            ref,
                            'Monthly',
                            ExpenseFilterType.monthly,
                            selectedTimeFilter,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    const DateRangeFilterSection(),

                    const SizedBox(height: 22),
                    // CATEGORY FILTERS
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          buildCategoryChip(
                            ref,
                            'All',
                            null,
                            selectedCategoryFilter,
                          ),

                          ...categories.map((category) {
                            return buildCategoryChip(
                              ref,
                              category.name,
                              category.name,
                              selectedCategoryFilter,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overview',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '₹${totalSpend.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            children: [
                              Expanded(
                                child: buildDashboardMetric(
                                  'Monthly',
                                  monthlySpend,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: buildDashboardMetric(
                                  'Weekly',
                                  weeklySpend,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          '${filteredExpenses.length} items',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
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
                    child: Center(child: Text('No expenses found')),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        return ExpenseTile(expense: filteredExpenses[index]);
                      },
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget buildDashboardMetric(String title, double value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),

          const SizedBox(height: 8),

          Text(
            '₹${value.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
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
      padding: const EdgeInsets.only(right: 10),
      child: FilterChipItem(
        label: label,
        selected: selected == filter,
        onTap: () {
          ref.read(expenseTimeFilterProvider.notifier).state = filter;
        },
      ),
    );
  }

  Widget buildCategoryChip(
    WidgetRef ref,
    String label,
    String? category,
    String? selected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChipItem(
        label: label,
        selected: selected == category,
        onTap: () {
          ref.read(expenseCategoryFilterProvider.notifier).state = category;
        },
      ),
    );
  }
}
