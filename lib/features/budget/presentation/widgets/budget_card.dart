import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/utils/budget_status_utils.dart';

class BudgetCard extends StatelessWidget {
  final String category;

  final double spent;

  final double total;

  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.total,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = total - spent;

    final progress = total == 0 ? 0.0 : (spent / total).clamp(0.0, 1.0);

    final health = BudgetStatusUtils.getHealth(spent: spent, total: total);

    final healthColor = BudgetStatusUtils.color(health);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: healthColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        BudgetStatusUtils.label(health),
                        style: TextStyle(
                          color: healthColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(healthColor),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${spent.toStringAsFixed(0)} / ₹${total.toStringAsFixed(0)}',
              ),
              Text(
                remaining >= 0
                    ? '₹${remaining.toStringAsFixed(0)} left'
                    : 'Exceeded ₹${remaining.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  color: healthColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
