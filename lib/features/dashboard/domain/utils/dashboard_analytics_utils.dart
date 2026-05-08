import '../../../expenses/domain/models/expense_model.dart';

class DashboardAnalyticsUtils {
  static double calculateTotalSpend(
    List<ExpenseModel> expenses,
  ) {
    return expenses.fold(
      0,
      (sum, expense) =>
          sum + expense.myShare,
    );
  }

  static double calculateMonthlySpend(
    List<ExpenseModel> expenses,
  ) {
    final now = DateTime.now();

    return expenses
        .where(
          (expense) =>
              expense.createdAt.month ==
                  now.month &&
              expense.createdAt.year ==
                  now.year,
        )
        .fold(
          0,
          (sum, expense) =>
              sum +
              expense.myShare,
        );
  }

  static double calculateWeeklySpend(
    List<ExpenseModel> expenses,
  ) {
    final now = DateTime.now();

    return expenses
        .where(
          (expense) =>
              now
                  .difference(
                    expense.createdAt,
                  )
                  .inDays <=
              7,
        )
        .fold(
          0,
          (sum, expense) =>
              sum +
              expense.myShare,
        );
  }
}