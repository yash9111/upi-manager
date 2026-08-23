class BudgetHealthScore {
  static int calculate({
    required double budget,
    required double spent,
  }) {
    if (budget <= 0) {
      return 100;
    }

    final ratio = spent / budget;

    if (ratio <= 0.5) {
      return 100;
    }

    if (ratio <= 0.7) {
      return 90;
    }

    if (ratio <= 0.85) {
      return 80;
    }

    if (ratio <= 1.0) {
      return 65;
    }

    if (ratio <= 1.2) {
      return 40;
    }

    return 20;
  }
}