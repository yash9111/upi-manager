import '../../../expenses/domain/models/expense_model.dart';
import '../models/friend_balance_model.dart';

class FriendBalanceCalculator {
  static List<FriendBalanceModel>
      calculateBalances(
    List<ExpenseModel> expenses,
  ) {
    final Map<String,
            FriendBalanceModel>
        balances = {};

    for (final expense in expenses) {
      if (!expense.isShared) {
        continue;
      }

      for (final participant
          in expense.participants) {
        if (participant.isSettled) {
          continue;
        }

        final key =
            participant.name
                .trim()
                .toLowerCase();

        if (balances.containsKey(key)) {
          final existing =
              balances[key]!;

          balances[key] =
              FriendBalanceModel(
            expenseId:
                existing.expenseId,
            participantId:
                existing
                    .participantId,
            name: existing.name,
            pendingAmount:
                existing
                        .pendingAmount +
                    participant.amount,
            pendingTransactions:
                existing
                        .pendingTransactions +
                    1,
          );
        } else {
          balances[key] =
              FriendBalanceModel(
            expenseId: expense.id,
            participantId:
                participant.id,
            name:
                participant.name,
            pendingAmount:
                participant.amount,
            pendingTransactions:
                1,
          );
        }
      }
    }

    return balances.values.toList();
  }

  static double calculateTotalPending(
    List<ExpenseModel> expenses,
  ) {
    double total = 0;

    for (final expense in expenses) {
      if (!expense.isShared) {
        continue;
      }

      for (final participant
          in expense.participants) {
        if (!participant.isSettled) {
          total += participant.amount;
        }
      }
    }

    return total;
  }
}