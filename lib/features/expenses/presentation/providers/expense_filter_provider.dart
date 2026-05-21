import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/expense_filter_type.dart';

final expenseTimeFilterProvider =
    StateProvider<
        ExpenseFilterType>((ref) {
  return ExpenseFilterType.all;
});

final expenseCategoryFilterProvider =
    StateProvider<String?>((ref) {
  return null;
});