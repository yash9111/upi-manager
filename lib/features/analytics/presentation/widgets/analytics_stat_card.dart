import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AnalyticsStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AnalyticsStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  AppColors.softPrimary,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}