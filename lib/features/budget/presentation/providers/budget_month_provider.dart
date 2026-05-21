import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedBudgetMonthProvider =
    StateProvider<DateTime>((ref) {
  return DateTime.now();
});