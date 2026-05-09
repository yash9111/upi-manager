import 'package:intl/intl.dart';

import '../models/expense_model.dart';

class ExpenseGroupingUtils {
  static Map<String, List<ExpenseModel>>
      groupExpensesByDate(
    List<ExpenseModel> expenses,
  ) {
    final Map<String,
            List<ExpenseModel>>
        grouped = {};

    expenses.sort(
      (a, b) => b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    for (final expense in expenses) {
      final key =
          getFormattedDateLabel(
        expense.createdAt,
      );

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(expense);
    }

    return grouped;
  }

  static String getFormattedDateLabel(
    DateTime date,
  ) {
    final now = DateTime.now();

    final difference =
        now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }
}