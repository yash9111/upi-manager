import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/models/budget_model.dart';

class BudgetRepository {
  final Box<BudgetModel> _box =
      Hive.box<BudgetModel>(
    HiveBoxes.budgets,
  );

  List<BudgetModel> getBudgets() {
    return _box.values.toList();
  }

  Future<void> addBudget({
    required String category,
    required double amount,
    required int month,
    required int year,
  }) async {
    final existing =
        _box.values.where(
      (budget) =>
          budget.category ==
              category &&
          budget.month == month &&
          budget.year == year,
    );

    for (final item in existing) {
      await _box.delete(item.id);
    }

    final budget = BudgetModel(
      id: const Uuid().v4(),
      category: category,
      amount: amount,
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );

    await _box.put(
      budget.id,
      budget,
    );
  }

  Future<void> deleteBudget(
    String id,
  ) async {
    await _box.delete(id);
  }
}