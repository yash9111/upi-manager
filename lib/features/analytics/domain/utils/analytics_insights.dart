import '../../../expenses/domain/models/expense_model.dart';

class AnalyticsInsights {
  static String
      highestCategory(
    List<ExpenseModel> expenses,
  ) {
    if (expenses.isEmpty) {
      return 'No data';
    }

    final map =
        <String, double>{};

    for (final expense
        in expenses) {
      map.update(
        expense.category,
        (value) =>
            value +
            expense.myShare,
        ifAbsent: () =>
            expense.myShare,
      );
    }

    final top =
        map.entries.reduce(
      (a, b) =>
          a.value > b.value
              ? a
              : b,
    );

    return top.key;
  }

  static double
      highestExpense(
    List<ExpenseModel> expenses,
  ) {
    if (expenses.isEmpty) {
      return 0;
    }

    return expenses
        .map(
          (e) => e.myShare,
        )
        .reduce(
          (a, b) =>
              a > b ? a : b,
        );
  }

  static double
      averageDailySpend(
    List<ExpenseModel> expenses,
  ) {
    if (expenses.isEmpty) {
      return 0;
    }

    final total =
        expenses.fold(
      0.0,
      (sum, expense) =>
          sum +
          expense.myShare,
    );

    final firstDate =
        expenses
            .map(
              (e) =>
                  e.createdAt,
            )
            .reduce(
              (
                a,
                b,
              ) =>
                  a.isBefore(b)
                      ? a
                      : b,
            );

    final days =
        DateTime.now()
            .difference(
              firstDate,
            )
            .inDays +
        1;

    return total / days;
  }
}