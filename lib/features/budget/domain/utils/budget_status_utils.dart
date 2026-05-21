import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum BudgetHealth {
  healthy,
  warning,
  danger,
  exceeded,
}

class BudgetStatusUtils {
  static BudgetHealth getHealth({
    required double spent,
    required double total,
  }) {
    if (total == 0) {
      return BudgetHealth.healthy;
    }

    final percent = spent / total;

    if (percent >= 1) {
      return BudgetHealth.exceeded;
    }

    if (percent >= 0.9) {
      return BudgetHealth.danger;
    }

    if (percent >= 0.7) {
      return BudgetHealth.warning;
    }

    return BudgetHealth.healthy;
  }

  static Color color(
    BudgetHealth health,
  ) {
    switch (health) {
      case BudgetHealth.healthy:
        return AppColors.success;

      case BudgetHealth.warning:
        return AppColors.warning;

      case BudgetHealth.danger:
        return Colors.deepOrange;

      case BudgetHealth.exceeded:
        return AppColors.danger;
    }
  }

  static String label(
    BudgetHealth health,
  ) {
    switch (health) {
      case BudgetHealth.healthy:
        return 'On Track';

      case BudgetHealth.warning:
        return 'Be Careful';

      case BudgetHealth.danger:
        return 'Likely To Exceed';

      case BudgetHealth.exceeded:
        return 'Exceeded';
    }
  }
}