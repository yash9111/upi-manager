class SplitCalculator {
  SplitCalculator._();

  static double calculateMyShare({
    required double totalAmount,
    required int peopleCount,
  }) {
    return totalAmount / peopleCount;
  }

  static double calculatePendingAmount({
    required double totalAmount,
    required double myShare,
  }) {
    return totalAmount - myShare;
  }
}