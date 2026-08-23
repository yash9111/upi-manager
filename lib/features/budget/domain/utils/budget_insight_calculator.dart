import '../../../expenses/domain/models/expense_model.dart';
import '../models/budget_insight_model.dart';
import '../models/budget_model.dart';

class BudgetInsightCalculator {
  static BudgetInsightModel calculate({
    required List<ExpenseModel> expenses,
    required List<BudgetModel> budgets,
    required DateTime month,
  }) {
    final monthlyExpenses =
        expenses.where(
      (expense) {
        return expense.createdAt.month ==
                month.month &&
            expense.createdAt.year ==
                month.year;
      },
    ).toList();

    final monthlyBudgets =
        budgets.where(
      (budget) {
        return budget.month ==
                month.month &&
            budget.year ==
                month.year;
      },
    ).toList();

    final totalBudget =
        monthlyBudgets.fold(
      0.0,
      (sum, budget) =>
          sum + budget.amount,
    );

    final totalSpent =
        monthlyExpenses.fold(
      0.0,
      (sum, expense) =>
          sum + expense.myShare,
    );

    final remaining =
        totalBudget - totalSpent;

    final progress =
        totalBudget == 0
            ? 0
            : totalSpent /
                totalBudget;

    final categoryMap =
        <String, double>{};

    for (final expense
        in monthlyExpenses) {
      categoryMap.update(
        expense.category,
        (value) =>
            value +
            expense.myShare,
        ifAbsent: () =>
            expense.myShare,
      );
    }

    String topCategory =
        'No Data';

    double topCategorySpend =
        0;

    if (categoryMap.isNotEmpty) {
      final top =
          categoryMap.entries
              .reduce(
        (a, b) =>
            a.value >
                    b.value
                ? a
                : b,
      );

      topCategory = top.key;
      topCategorySpend =
          top.value;
    }

    final today =
        DateTime.now();

    final daysPassed =
        today.day;

    final daysInMonth =
        DateTime(
          today.year,
          today.month + 1,
          0,
        ).day;

    final projected =
        daysPassed == 0
            ? totalSpent
            : (totalSpent /
                    daysPassed) *
                daysInMonth;

    return BudgetInsightModel(
      totalBudget:
          totalBudget,
      totalSpent:
          totalSpent,
      remaining:
          remaining,
      progress:
          progress.toDouble(),
      topCategory:
          topCategory,
      topCategorySpend:
          topCategorySpend,
      projectedMonthEndSpend:
          projected,
      projectedDifference:
          projected -
              totalBudget,
    );
  }
}