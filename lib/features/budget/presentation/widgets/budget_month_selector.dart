import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/budget_month_provider.dart';

class BudgetMonthSelector
    extends ConsumerWidget {
  const BudgetMonthSelector({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final selectedMonth =
        ref.watch(
      selectedBudgetMonthProvider,
    );

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref
                  .read(
                    selectedBudgetMonthProvider
                        .notifier,
                  )
                  .state = DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
              );
            },
            child: const Icon(
              Icons.chevron_left,
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                DateFormat(
                  'MMMM yyyy',
                ).format(
                  selectedMonth,
                ),
                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              ref
                  .read(
                    selectedBudgetMonthProvider
                        .notifier,
                  )
                  .state = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
              );
            },
            child: const Icon(
              Icons.chevron_right,
            ),
          ),
        ],
      ),
    );
  }
}