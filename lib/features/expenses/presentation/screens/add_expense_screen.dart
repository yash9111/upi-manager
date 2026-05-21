import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/category/presentation/providers/category_provider.dart';
import 'package:upi_tracker/features/expenses/presentation/providers/temp_participants_provider.dart';
import 'package:upi_tracker/features/expenses/presentation/widgets/participants_section.dart';
import 'package:uuid/uuid.dart';
import '../widgets/saved_people_section.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_date_picker_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/models/expense_model.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  bool isShared = false;

  String selectedCategory = '';
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    if (selectedCategory.isEmpty && categories.isNotEmpty) {
      selectedCategory = categories.first.name;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
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

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SwitchListTile(
                value: isShared,
                activeThumbColor: AppColors.primary,
                title: const Text('Shared Expense'),
                onChanged: (value) {
                  setState(() {
                    isShared = value;
                  });
                },
              ),
            ),
            if (isShared) ...[
              const SizedBox(height: 24),
              const SavedPeopleSection(),

              const SizedBox(height: 24),
              const ParticipantsSection(),
            ],
            const SizedBox(height: 40),

            AppPrimaryButton(text: 'Save Expense', onTap: saveExpense),
          ],
        ),
      ),
    );
  }

  Future<void> saveExpense() async {
    final amount = double.tryParse(amountController.text);

    if (amount == null) {
      return;
    }

    final participants = ref.read(tempParticipantsProvider);

    double myShare = amount;

    if (isShared && participants.isNotEmpty) {
      myShare = amount / (participants.length + 1);

      ref.read(tempParticipantsProvider.notifier).updateSplitAmounts(amount);
    }

    final updatedParticipants = ref.read(tempParticipantsProvider);

    final expense = ExpenseModel(
      id: const Uuid().v4(),
      totalAmount: amount,
      myShare: myShare,
      category: selectedCategory,
      note: noteController.text.trim().isEmpty
          ? selectedCategory
          : noteController.text.trim(),
      isShared: isShared,
      createdAt: selectedDate,
      participants: updatedParticipants,
    );

    await ref.read(expensesProvider.notifier).addExpense(expense);

    ref.read(tempParticipantsProvider.notifier).clearParticipants();

    if (!mounted) return;

    Navigator.pop(context);
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
}
