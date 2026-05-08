import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FilterChipItem
    extends StatelessWidget {
  final String label;

  final bool selected;

  final VoidCallback onTap;

  const FilterChipItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            30,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : AppColors
                    .textPrimary,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }
}