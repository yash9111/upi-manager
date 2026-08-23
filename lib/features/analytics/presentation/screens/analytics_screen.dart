import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/analytics/domain/utils/analytics_insights.dart';
import 'package:upi_tracker/features/analytics/presentation/widgets/category_pie_chart.dart';
import 'package:upi_tracker/features/analytics/presentation/widgets/insight_card.dart';

import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../domain/utils/analytics_utils.dart';
import '../widgets/analytics_stat_card.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/top_category_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);

    final categoryData = AnalyticsUtils.categoryBreakdown(expenses);

    final monthlyData = AnalyticsUtils.monthlyTrend(expenses);

    final totalSpent = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.myShare,
    );

    final avgExpense = expenses.isEmpty ? 0 : totalSpent / expenses.length;

    final highestCategory = AnalyticsInsights.highestCategory(expenses);

    final highestExpense = AnalyticsInsights.highestExpense(expenses);

    final averageDailySpend = AnalyticsInsights.averageDailySpend(expenses);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analytics',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text('Understand your spending'),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: AnalyticsStatCard(
                      title: 'Total Spent',
                      value: '₹${totalSpent.toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: AnalyticsStatCard(
                      title: 'Average',
                      value: '₹${avgExpense.toStringAsFixed(0)}',
                      icon: Icons.analytics_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Monthly Trend',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: MonthlyTrendChart(data: monthlyData),
              ),
              const SizedBox(height: 28),

              const Text(
                'Category Distribution',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: CategoryPieChart(categories: categoryData),
              ),
              const SizedBox(height: 28),

              const Text(
                'Insights',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),

              InsightCard(
                title: 'Highest Spending Category',
                value: highestCategory,
                icon: Icons.local_fire_department,
              ),

              InsightCard(
                title: 'Largest Expense',
                value: '₹${highestExpense.toStringAsFixed(0)}',
                icon: Icons.currency_rupee,
              ),

              InsightCard(
                title: 'Average Daily Spend',
                value: '₹${averageDailySpend.toStringAsFixed(0)}',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 14),

              const Text(
                'Top Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              ...categoryData
                  .take(5)
                  .map(
                    (category) => TopCategoryCard(
                      category: category.category,
                      amount: category.amount,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
