import '../../../expenses/domain/models/expense_model.dart';

class BudgetUtils {
  static double calculateSpent({
    required String category,
    required List<ExpenseModel>
        expenses,
    required int month,
    required int year,
  }) {
    return expenses
        .where(
          (expense) =>
              expense.category ==
                  category &&
              expense.createdAt.month ==
                  month &&
              expense.createdAt.year ==
                  year,
        )
        .fold(
          0,
          (sum, expense) =>
              sum +
              expense.myShare,
        );
  }

  static double progress({
    required double spent,
    required double budget,
  }) {
    if (budget == 0) return 0;

    return spent / budget;
  }
}