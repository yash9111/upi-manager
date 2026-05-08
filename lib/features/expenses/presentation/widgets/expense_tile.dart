import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:upi_tracker/features/expenses/presentation/screens/edit_expense_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/expense_model.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseTile({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditExpenseScreen(
          expense: expense,
        ),
      ),
    );
  },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  AppColors.primary
                      .withOpacity(0.1),
              child: Icon(
                getCategoryIcon(),
                color: AppColors.primary,
              ),
            ),
      
            const SizedBox(width: 16),
      
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    expense.note,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .w600,
                      fontSize: 16,
                    ),
                  ),
      
                  const SizedBox(
                    height: 6,
                  ),
      
                  Text(
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(
                      expense.createdAt,
                    ),
                    style:
                        const TextStyle(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),
      
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .end,
              children: [
                Text(
                  '₹${expense.myShare.toStringAsFixed(0)}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
      
                const SizedBox(
                  height: 6,
                ),
      
                Text(
                  expense.category,
                  style:
                      const TextStyle(
                    color: AppColors
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData getCategoryIcon() {
    switch (expense.category) {
      case 'Food':
        return Icons.restaurant;

      case 'Travel':
        return Icons.directions_car;

      case 'Shopping':
        return Icons.shopping_bag;

      case 'Bills':
        return Icons.receipt_long;

      default:
        return Icons.wallet;
    }
  }
}