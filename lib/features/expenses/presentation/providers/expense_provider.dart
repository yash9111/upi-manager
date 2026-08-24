import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../splits/domain/models/split_participant_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../../domain/models/expense_model.dart';

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expensesProvider =
    StateNotifierProvider<
        ExpenseNotifier,
        List<ExpenseModel>>((ref) {
  return ExpenseNotifier(
    ref.read(expenseRepositoryProvider),
  );
});

class ExpenseNotifier
    extends StateNotifier<List<ExpenseModel>> {
  final ExpenseRepository repository;

  ExpenseNotifier(this.repository)
      : super(repository.getExpenses());

  void loadExpenses() {
    state = repository.getExpenses();
  }

  Future<bool> expenseExists(
    String expenseId,
  ) async {
    return repository.exists(expenseId);
  }

  Future<void> addExpense(
    ExpenseModel expense,
  ) async {
    await repository.addExpense(expense);

    loadExpenses();
  }

  Future<void> updateExpense(
    ExpenseModel expense,
  ) async {
    await repository.updateExpense(expense);

    loadExpenses();
  }

  Future<void> deleteExpense(
    String expenseId,
  ) async {
    await repository.deleteExpense(expenseId);

    loadExpenses();
  }

  Future<void> settleParticipant({
    required String expenseId,
    required String participantId,
  }) async {
    final expense = state.firstWhere(
      (element) => element.id == expenseId,
    );

    final updatedParticipants =
        expense.participants.map((participant) {
      if (participant.id == participantId) {
        return SplitParticipantModel(
          id: participant.id,
          name: participant.name,
          amount: participant.amount,
          isSettled: true,
        );
      }

      return participant;
    }).toList();

    final updatedExpense = ExpenseModel(
      id: expense.id,
      totalAmount: expense.totalAmount,
      myShare: expense.myShare,
      category: expense.category,
      note: expense.note,
      isShared: expense.isShared,
      createdAt: expense.createdAt,
      participants: updatedParticipants,
    );

    await repository.updateExpense(
      updatedExpense,
    );

    loadExpenses();
  }
}