import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:upi_tracker/core/theme/app_colors.dart';
import 'package:upi_tracker/core/widgets/app_date_picker_field.dart';
import 'package:upi_tracker/core/widgets/app_primary_button.dart';
import 'package:upi_tracker/core/widgets/app_text_field.dart';

import 'package:upi_tracker/features/category/presentation/providers/category_provider.dart';
import 'package:upi_tracker/features/expenses/domain/models/expense_model.dart';
import 'package:upi_tracker/features/expenses/presentation/providers/expense_provider.dart';
import 'package:upi_tracker/features/expenses/presentation/providers/temp_participants_provider.dart';
import 'package:upi_tracker/features/expenses/presentation/widgets/participants_section.dart';
import 'package:upi_tracker/features/expenses/presentation/widgets/saved_people_section.dart';

import '../../domain/models/imported_transaction.dart';
import '../providers/imported_transaction_provider.dart';

class ImportedTransactionReviewScreen extends ConsumerStatefulWidget {
  final ImportedTransaction transaction;

  const ImportedTransactionReviewScreen({super.key, required this.transaction});

  @override
  ConsumerState<ImportedTransactionReviewScreen> createState() =>
      _ImportedTransactionReviewScreenState();
}

class _ImportedTransactionReviewScreenState
    extends ConsumerState<ImportedTransactionReviewScreen> {
  final noteController = TextEditingController();

  bool isShared = false;

  String selectedCategory = '';

  late DateTime selectedDate;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.transaction.transactionDate;

    noteController.text = widget.transaction.merchant ?? '';
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  bool get _isDebit => widget.transaction.type == ImportedTransactionType.debit;

  bool get _isCredit =>
      widget.transaction.type == ImportedTransactionType.credit;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    if (selectedCategory.isEmpty && categories.isNotEmpty && _isDebit) {
      selectedCategory = _findBestCategory(categories);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountCard(),

              const SizedBox(height: 24),

              _buildTransactionDetails(),

              const SizedBox(height: 24),

              if (_isDebit) _buildExpenseSection(categories),

              if (_isCredit) ...[const SizedBox(height: 4), _buildCreditInfo()],

              const SizedBox(height: 24),

              _buildOriginalSms(),

              const SizedBox(height: 32),

              if (_isDebit) ...[
                AppPrimaryButton(
                  text: _isProcessing ? 'Processing...' : 'Add Expense',
                  onTap: _isProcessing ? () {} : () => saveExpense(),
                ),

                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : ignoreTransaction,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  label: Text(
                    _isCredit ? 'Ignore Credit' : 'Ignore Transaction',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger.withOpacity(.35)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AMOUNT
  // ---------------------------------------------------------------------------

  Widget _buildAmountCard() {
    final transaction = widget.transaction;

    final gradientColors = _isDebit
        ? [AppColors.primary, AppColors.secondary]
        : [AppColors.success, const Color(0xFF0F766E)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _isDebit
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                _isDebit ? 'Expense candidate' : 'Credit received',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            '${_isDebit ? '- ' : '+ '}₹${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -.5,
            ),
          ),

          if (transaction.merchant != null &&
              transaction.merchant!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),

            Text(
              transaction.merchant!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 4),

          Text(
            _formatDate(transaction.transactionDate),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CREDIT INFO
  // ---------------------------------------------------------------------------

  Widget _buildCreditInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.success,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Credit transaction',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                SizedBox(height: 5),
                Text(
                  'This is money received in your account. '
                  'It will not be added as an expense.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TRANSACTION DETAILS
  // ---------------------------------------------------------------------------

  Widget _buildTransactionDetails() {
    final transaction = widget.transaction;

    return _section(
      title: 'Transaction Details',
      icon: Icons.receipt_long_rounded,
      child: Column(
        children: [
          _detailRow(
            'Transaction Date',
            _formatDate(transaction.transactionDate),
          ),

          if (transaction.bankName != null &&
              transaction.bankName!.trim().isNotEmpty)
            _detailRow('Bank', transaction.bankName!),

          if (transaction.accountNumber != null &&
              transaction.accountNumber!.trim().isNotEmpty)
            _detailRow('Account', transaction.accountNumber!),

          if (transaction.upiId != null && transaction.upiId!.trim().isNotEmpty)
            _detailRow('UPI ID', transaction.upiId!),

          if (transaction.referenceNumber != null &&
              transaction.referenceNumber!.trim().isNotEmpty)
            _detailRow('Reference', transaction.referenceNumber!),

          if (transaction.availableBalance != null)
            _detailRow(
              'Available Balance',
              '₹${transaction.availableBalance!.toStringAsFixed(2)}',
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EXPENSE DETAILS
  // ---------------------------------------------------------------------------

  Widget _buildExpenseSection(List categories) {
    return _section(
      title: 'Expense Details',
      icon: Icons.edit_note_rounded,
      child: Column(
        children: [
          _buildCategorySelector(categories),

          const Divider(height: 28),

          AppDatePickerField(selectedDate: selectedDate, onTap: pickDate),

          const Divider(height: 28),

          AppTextField(
            controller: noteController,
            hint: 'Expense note',
            prefixIcon: const Icon(Icons.notes_rounded),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: SwitchListTile(
              value: isShared,
              activeThumbColor: AppColors.primary,
              title: const Text(
                'Shared Expense',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                isShared
                    ? 'Split this expense with others'
                    : 'This expense is only mine',
              ),
              onChanged: (value) {
                setState(() {
                  isShared = value;
                });

                if (!value) {
                  ref
                      .read(tempParticipantsProvider.notifier)
                      .clearParticipants();
                }
              },
            ),
          ),

          if (isShared) ...[
            const SizedBox(height: 20),
            const SavedPeopleSection(),
            const SizedBox(height: 20),
            const ParticipantsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySelector(List categories) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButton<String>(
        value: selectedCategory.isEmpty ? null : selectedCategory,
        hint: const Text('Select category'),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category.name,
            child: Row(
              children: [
                const Icon(Icons.category_outlined, size: 20),
                const SizedBox(width: 10),
                Text(category.name),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            selectedCategory = value;
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ORIGINAL SMS
  // ---------------------------------------------------------------------------

  Widget _buildOriginalSms() {
    return _section(
      title: 'Original SMS',
      icon: Icons.sms_outlined,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
        title: const Text(
          'View original message',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(
              widget.transaction.rawSms,
              style: const TextStyle(fontSize: 12.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION / DETAIL HELPERS
  // ---------------------------------------------------------------------------

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border, width: .5),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),

          const SizedBox(width: 16),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY
  // ---------------------------------------------------------------------------

  String _findBestCategory(List categories) {
    final merchant = (widget.transaction.merchant ?? '').toLowerCase();

    if (merchant.contains('swiggy') ||
        merchant.contains('zomato') ||
        merchant.contains('food') ||
        merchant.contains('restaurant')) {
      final food = categories.where(
        (category) => category.name.toString().toLowerCase() == 'food',
      );

      if (food.isNotEmpty) {
        return food.first.name;
      }
    }

    return categories.first.name;
  }

  // ---------------------------------------------------------------------------
  // DATE
  // ---------------------------------------------------------------------------

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: selectedDate,
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      selectedDate = pickedDate;
    });
  }

  // ---------------------------------------------------------------------------
  // ADD EXPENSE
  // ---------------------------------------------------------------------------

  Future<void> saveExpense() async {
    // Defensive check.
    //
    // Even though the UI doesn't show the Add Expense
    // button for credits, we explicitly prevent credits
    // from reaching ExpenseModel creation.
    if (!_isDebit) {
      _showMessage('Credit transactions cannot be added as expenses.');
      return;
    }

    if (selectedCategory.isEmpty) {
      _showMessage('Please select a category.');
      return;
    }

    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final transaction = widget.transaction;

    final participants = ref.read(tempParticipantsProvider);

    double myShare = transaction.amount;

    if (isShared && participants.isNotEmpty) {
      myShare = transaction.amount / (participants.length + 1);

      ref
          .read(tempParticipantsProvider.notifier)
          .updateSplitAmounts(transaction.amount);
    }

    final updatedParticipants = ref.read(tempParticipantsProvider);

    final expense = ExpenseModel(
      id: 'expense_imported_${transaction.id}',
      totalAmount: transaction.amount,
      myShare: myShare,
      category: selectedCategory,
      note: noteController.text.trim().isEmpty
          ? selectedCategory
          : noteController.text.trim(),
      isShared: isShared,
      createdAt: selectedDate,
      participants: updatedParticipants,
    );

    try {
      final expenseNotifier = ref.read(expensesProvider.notifier);

      final alreadyExists = await expenseNotifier.expenseExists(expense.id);

      if (alreadyExists) {
        await ref
            .read(importedTransactionsProvider.notifier)
            .markAsProcessed(transaction.id);

        ref.read(tempParticipantsProvider.notifier).clearParticipants();

        if (!mounted) {
          return;
        }

        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This transaction was already added as an expense.'),
          ),
        );

        return;
      }

      await expenseNotifier.addExpense(expense);

      await ref
          .read(importedTransactionsProvider.notifier)
          .markAsProcessed(transaction.id);

      ref.read(tempParticipantsProvider.notifier).clearParticipants();

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage('Could not add expense. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // IGNORE
  // ---------------------------------------------------------------------------

  Future<void> ignoreTransaction() async {
    if (_isProcessing) {
      return;
    }

    final confirmed = await _showIgnoreConfirmation();

    if (!confirmed) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await ref
          .read(importedTransactionsProvider.notifier)
          .markAsIgnored(widget.transaction.id);

      ref.read(tempParticipantsProvider.notifier).clearParticipants();

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showMessage('Could not ignore this transaction.');
    }
  }

  Future<bool> _showIgnoreConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ignore transaction?'),
          content: Text(
            _isCredit
                ? 'This credit will remain in your imported transaction history, but it will not be processed as an expense.'
                : 'This transaction will be marked as ignored and will not be added as an expense.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Ignore'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ---------------------------------------------------------------------------
  // MESSAGE
  // ---------------------------------------------------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------------
  // DATE FORMAT
  // ---------------------------------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} • '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
