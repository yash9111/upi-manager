import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/models/expense_model.dart';

class ExpenseRepository {
  final Box<ExpenseModel> _expenseBox =
      Hive.box<ExpenseModel>(
    HiveBoxes.expenses,
  );

  List<ExpenseModel> getExpenses() {
    return _expenseBox.values.toList();
  }

  Future<void> addExpense(
    ExpenseModel expense,
  ) async {
    await _expenseBox.put(
      expense.id,
      expense,
    );
  }

  Future<void> updateExpense(
    ExpenseModel expense,
  ) async {
    await _expenseBox.put(
      expense.id,
      expense,
    );
  }
  Future<void> deleteExpense(
  String expenseId,
) async {
  await _expenseBox.delete(
    expenseId,
  );
}
}