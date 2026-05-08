class FriendBalanceModel {
  final String expenseId;

  final String participantId;

  final String name;

  final double pendingAmount;

  final int pendingTransactions;

  FriendBalanceModel({
    required this.expenseId,
    required this.participantId,
    required this.name,
    required this.pendingAmount,
    required this.pendingTransactions,
  });
}