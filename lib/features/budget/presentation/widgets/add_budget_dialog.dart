import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/core/theme/app_colors.dart';

import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../providers/budget_provider.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final String? initialCategory;

  final double? initialAmount;

  final DateTime? initialMonth;

  const AddBudgetDialog({
    super.key,
    this.initialCategory,
    this.initialAmount,
    this.initialMonth,
  });

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final amountController = TextEditingController();

  DateTime selectedMonth = DateTime.now();

  String? selectedCategory;

  @override
  void initState() {
    super.initState();

    if (widget.initialAmount != null) {
      amountController.text = widget.initialAmount!.toStringAsFixed(0);
    }

    selectedMonth = widget.initialMonth ?? DateTime.now();

    selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    if (categories.isNotEmpty && selectedCategory == null) {
      selectedCategory = categories.first.name;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialAmount == null ? 'Create Budget' : 'Update Budget',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Set monthly category spending limit',
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 28),

            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(22),
              ),
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Budget Amount',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            AppTextField(
              controller: amountController,
              hint: 'Enter amount',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.currency_rupee),
            ),

            const SizedBox(height: 22),

            GestureDetector(
              onTap: pickMonth,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        '${months[selectedMonth.month - 1]} ${selectedMonth.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                text: widget.initialAmount == null
                    ? 'Create Budget'
                    : 'Update Budget',
                onTap: saveBudget,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveBudget() async {
    final amount = double.tryParse(amountController.text);

    if (amount == null || selectedCategory == null) {
      return;
    }

    await ref
        .read(budgetsProvider.notifier)
        .addBudget(
          category: selectedCategory!,
          amount: amount,
          month: selectedMonth.month,
          year: selectedMonth.year,
        );

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: selectedMonth,
      helpText: 'Select Month',
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked;
      });
    }
  }

  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
