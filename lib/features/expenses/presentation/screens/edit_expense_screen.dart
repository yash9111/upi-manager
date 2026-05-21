import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/category/presentation/providers/category_provider.dart';

import '../../../../core/widgets/app_date_picker_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/models/expense_model.dart';
import '../providers/expense_provider.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  late TextEditingController amountController;

  late TextEditingController noteController;

  late String selectedCategory;

  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    amountController = TextEditingController(
      text: widget.expense.totalAmount.toString(),
    );

    noteController = TextEditingController(text: widget.expense.note);

    selectedCategory = widget.expense.category;

    selectedDate = widget.expense.createdAt;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),

        actions: [
          IconButton(
            onPressed: deleteExpense,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: amountController,
              hint: 'Enter amount',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.currency_rupee),
            ),

            const SizedBox(height: 20),

            AppTextField(
              controller: noteController,
              hint: 'Expense note',
              prefixIcon: const Icon(Icons.notes),
            ),

            const SizedBox(height: 20),

            AppDatePickerField(selectedDate: selectedDate, onTap: pickDate),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                    selectedCategory = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 40),

            AppPrimaryButton(text: 'Update Expense', onTap: updateExpense),
          ],
        ),
      ),
    );
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: selectedDate,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> updateExpense() async {
    final amount = double.tryParse(amountController.text);

    if (amount == null) {
      return;
    }

    final updatedExpense = ExpenseModel(
      id: widget.expense.id,
      totalAmount: amount,
      myShare: widget.expense.myShare,
      category: selectedCategory,
      note: noteController.text.trim().isEmpty
          ? selectedCategory
          : noteController.text.trim(),
      isShared: widget.expense.isShared,
      createdAt: selectedDate,
      participants: widget.expense.participants,
    );

    await ref.read(expensesProvider.notifier).updateExpense(updatedExpense);

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> deleteExpense() async {
    await ref.read(expensesProvider.notifier).deleteExpense(widget.expense.id);

    if (!mounted) return;

    Navigator.pop(context);
  }
}
