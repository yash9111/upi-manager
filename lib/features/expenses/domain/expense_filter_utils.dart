import 'package:upi_tracker/features/expenses/domain/enums/expense_category_filter.dart';
import 'package:upi_tracker/features/expenses/domain/enums/expense_filter_type.dart';
import 'package:upi_tracker/features/expenses/domain/models/expense_model.dart';


class ExpenseFilterUtils {
  static List<ExpenseModel> filterExpenses({
    required List<ExpenseModel> expenses,
    required ExpenseFilterType timeFilter,
    required ExpenseCategoryFilter categoryFilter,
    required DateTime? selectedDate,
  }) {
    List<ExpenseModel> filtered =
        List.from(expenses);

    final now = DateTime.now();

    // DATE FILTER (HIGHEST PRIORITY)

    if (selectedDate != null) {
      filtered = filtered.where((expense) {
        return expense.createdAt.day ==
                selectedDate.day &&
            expense.createdAt.month ==
                selectedDate.month &&
            expense.createdAt.year ==
                selectedDate.year;
      }).toList();
    }

    // TIME FILTER

    switch (timeFilter) {
      case ExpenseFilterType.today:
        filtered = filtered.where((expense) {
          return expense.createdAt.day ==
                  now.day &&
              expense.createdAt.month ==
                  now.month &&
              expense.createdAt.year ==
                  now.year;
        }).toList();

      case ExpenseFilterType.weekly:
        filtered = filtered.where((expense) {
          return now
                  .difference(
                    expense.createdAt,
                  )
                  .inDays <=
              7;
        }).toList();

      case ExpenseFilterType.monthly:
        filtered = filtered.where((expense) {
          return expense.createdAt.month ==
                  now.month &&
              expense.createdAt.year ==
                  now.year;
        }).toList();

      case ExpenseFilterType.all:
        break;
    }

    // CATEGORY FILTER

    switch (categoryFilter) {
      case ExpenseCategoryFilter.food:
        filtered = filtered.where((expense) {
          return expense.category ==
              'Food';
        }).toList();

      case ExpenseCategoryFilter.travel:
        filtered = filtered.where((expense) {
          return expense.category ==
              'Travel';
        }).toList();

      case ExpenseCategoryFilter.shopping:
        filtered = filtered.where((expense) {
          return expense.category ==
              'Shopping';
        }).toList();

      case ExpenseCategoryFilter.bills:
        filtered = filtered.where((expense) {
          return expense.category ==
              'Bills';
        }).toList();

      case ExpenseCategoryFilter.entertainment:
        filtered = filtered.where((expense) {
          return expense.category ==
              'Entertainment';
        }).toList();

      case ExpenseCategoryFilter.all:
        break;
    }

    // SORT DESCENDING

    filtered.sort(
      (a, b) => b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    return filtered;
  }
}