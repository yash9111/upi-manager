import '../../../expenses/domain/models/expense_model.dart';
import '../../../splits/domain/models/split_participant_model.dart';

import '../models/imported_transaction.dart';

class ImportedTransactionExpenseMapper {
  const ImportedTransactionExpenseMapper();

  ExpenseModel createExpense({
    required ImportedTransaction transaction,
    required String category,
    required String note,
    required bool isShared,
    required List<SplitParticipantModel>
        participants,
    required double myShare,
  }) {
    return ExpenseModel(
      id: _generateExpenseId(
        transaction,
      ),
      totalAmount: transaction.amount,
      myShare: myShare,
      category: category,
      note: note,
      isShared: isShared,
      createdAt:
          transaction.transactionDate,
      participants: participants,
    );
  }

  String _generateExpenseId(
    ImportedTransaction transaction,
  ) {
    return 'expense_imported_${transaction.id}';
  }
}