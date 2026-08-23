class BudgetInsightModel {
  final double totalBudget;

  final double totalSpent;

  final double remaining;

  final double progress;

  final String topCategory;

  final double topCategorySpend;

  final double projectedMonthEndSpend;

  final double projectedDifference;

  const BudgetInsightModel({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.progress,
    required this.topCategory,
    required this.topCategorySpend,
    required this.projectedMonthEndSpend,
    required this.projectedDifference,
  });
}