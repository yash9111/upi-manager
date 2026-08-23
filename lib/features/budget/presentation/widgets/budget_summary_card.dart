import 'package:flutter/material.dart';
import 'package:upi_tracker/features/budget/domain/models/budget_insight_model.dart';

import '../../../../core/theme/app_colors.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetInsightModel insights;

  const BudgetSummaryCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final percentage = (insights.progress * 100)
        .clamp(0, 100)
        .toStringAsFixed(0);

    final overspending = insights.projectedDifference > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softPrimary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Financial health overview',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softPrimary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          Text(
            '₹${insights.totalSpent.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            'of ₹${insights.totalBudget.toStringAsFixed(0)} budget used',
            style: const TextStyle(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 22),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: insights.progress.clamp(0, 1),
              minHeight: 12,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: buildMetric(
                  title: 'Remaining',
                  value: '₹${insights.remaining.abs().toStringAsFixed(0)}',
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: buildMetric(
                  title: 'Top Category',
                  value: insights.topCategory,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: overspending
                  ? AppColors.softDanger
                  : AppColors.softSuccess,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overspending ? 'Projected Overspend' : 'Projected Month End',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  '₹${insights.projectedMonthEndSpend.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  overspending
                      ? 'Likely to exceed budget by ₹${insights.projectedDifference.toStringAsFixed(0)}'
                      : 'You are currently on track',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMetric({required String title, required String value}) {
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

Widget buildMetricCard({required String title, required String value}) {
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
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
