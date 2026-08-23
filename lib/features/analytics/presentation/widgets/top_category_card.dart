import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TopCategoryCard
    extends StatelessWidget {
  final String category;
  final double amount;

  const TopCategoryCard({
    super.key,
    required this.category,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  AppColors.softPrimary,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.category,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}