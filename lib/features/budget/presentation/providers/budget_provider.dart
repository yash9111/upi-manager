import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/budget_repository.dart';
import '../../domain/models/budget_model.dart';

final budgetRepositoryProvider =
    Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

final budgetsProvider =
    StateNotifierProvider<
        BudgetNotifier,
        List<BudgetModel>>((ref) {
  return BudgetNotifier(
    ref.read(
      budgetRepositoryProvider,
    ),
  );
});

class BudgetNotifier
    extends StateNotifier<
        List<BudgetModel>> {
  final BudgetRepository
      repository;

  BudgetNotifier(
    this.repository,
  ) : super([]) {
    loadBudgets();
  }

  void loadBudgets() {
    state =
        repository.getBudgets();
  }

  Future<void> addBudget({
    required String category,
    required double amount,
    required int month,
    required int year,
  }) async {
    await repository.addBudget(
      category: category,
      amount: amount,
      month: month,
      year: year,
    );

    loadBudgets();
  }

  Future<void> deleteBudget(
    String id,
  ) async {
    await repository.deleteBudget(
      id,
    );

    loadBudgets();
  }
}