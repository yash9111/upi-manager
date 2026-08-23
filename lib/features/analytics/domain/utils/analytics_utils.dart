import '../../../expenses/domain/models/expense_model.dart';

import '../models/category_spending_model.dart';
import '../models/monthly_spending_model.dart';

class AnalyticsUtils {
  static List<CategorySpendingModel>
      categoryBreakdown(
    List<ExpenseModel> expenses,
  ) {
    final Map<String, double>
        categoryMap = {};

    for (final expense
        in expenses) {
      categoryMap.update(
        expense.category,
        (value) =>
            value +
            expense.myShare,
        ifAbsent: () =>
            expense.myShare,
      );
    }

    return categoryMap.entries
        .map(
          (entry) =>
              CategorySpendingModel(
            category:
                entry.key,
            amount:
                entry.value,
          ),
        )
        .toList()
      ..sort(
        (a, b) => b.amount
            .compareTo(
          a.amount,
        ),
      );
  }

  static List<MonthlySpendingModel>
      monthlyTrend(
    List<ExpenseModel> expenses,
  ) {
    final Map<String, double>
        monthMap = {};

    for (final expense
        in expenses) {
      final key =
          '${expense.createdAt.month}-${expense.createdAt.year}';

      monthMap.update(
        key,
        (value) =>
            value +
            expense.myShare,
        ifAbsent: () =>
            expense.myShare,
      );
    }

    return monthMap.entries
        .map(
          (entry) =>
              MonthlySpendingModel(
            month:
                entry.key,
            amount:
                entry.value,
          ),
        )
        .toList();
  }
}