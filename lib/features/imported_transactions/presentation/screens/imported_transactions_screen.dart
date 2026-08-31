import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/imported_transactions/presentation/screens/bulk_sms_import_screen.dart';

import '../../domain/models/imported_transaction.dart';
import '../providers/imported_transaction_provider.dart';
import 'imported_transaction_review_screen.dart';

class ImportedTransactionsScreen extends ConsumerStatefulWidget {
  const ImportedTransactionsScreen({super.key});

  @override
  ConsumerState<ImportedTransactionsScreen> createState() =>
      _ImportedTransactionsScreenState();
}

class _ImportedTransactionsScreenState
    extends ConsumerState<ImportedTransactionsScreen> {
  ImportedTransactionStatus? selectedStatus;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(importedTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BulkSmsImportScreen()),
            );
          },
          child: const Text(
            'Imported Transactions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(error),
        data: (transactions) {
          final filtered = _filterTransactions(transactions);

          return RefreshIndicator(
            onRefresh: () async {
              final result = await ref
                  .read(incomingSmsServiceProvider)
                  .processPendingSms();

              /*
   * processPendingSms() may have inserted new
   * transactions directly into Hive.
   *
   * Reload the provider AFTER processing.
   */
              ref.invalidate(importedTransactionsProvider);

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'SMS: ${result.totalSms} | '
                    'Parsed: ${result.parsed} | '
                    'Imported: ${result.imported} | '
                    'Duplicates: ${result.duplicates} | '
                    'Failed: ${result.failed}',
                  ),
                ),
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildSummaryCard(transactions)),

                SliverToBoxAdapter(child: _buildFilterChips()),

                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTransactionTile(filtered[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------

  Widget _buildSummaryCard(List<ImportedTransaction> transactions) {
    final pendingTransactions = transactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.pending,
        )
        .toList();

    final processedCount = transactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.processed,
        )
        .length;

    final ignoredCount = transactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.ignored,
        )
        .length;

    final pendingAmount = pendingTransactions
        .where(
          (transaction) => transaction.type == ImportedTransactionType.debit,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.sms_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Transaction Inbox',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _summaryMainValue(
                    value: pendingTransactions.length.toString(),
                    label: 'Pending review',
                  ),
                ),
                Container(width: 1, height: 48, color: Colors.white24),
                const SizedBox(width: 18),
                Expanded(
                  child: _summaryMainValue(
                    value: '₹${pendingAmount.toStringAsFixed(0)}',
                    label: 'Pending debit',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _summaryMiniStat(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Processed',
                    value: processedCount.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryMiniStat(
                    icon: Icons.remove_circle_outline_rounded,
                    label: 'Ignored',
                    value: ignoredCount.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryMiniStat(
                    icon: Icons.receipt_long_outlined,
                    label: 'Total',
                    value: transactions.length.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryMainValue({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _summaryMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTERS
  // ---------------------------------------------------------------------------

  Widget _buildFilterChips() {
    final statuses = [
      (label: 'All', status: null, icon: Icons.all_inbox_rounded),
      (
        label: 'Pending',
        status: ImportedTransactionStatus.pending,
        icon: Icons.pending_actions_rounded,
      ),
      (
        label: 'Processed',
        status: ImportedTransactionStatus.processed,
        icon: Icons.check_circle_outline_rounded,
      ),
      (
        label: 'Ignored',
        status: ImportedTransactionStatus.ignored,
        icon: Icons.remove_circle_outline_rounded,
      ),
    ];

    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = statuses[index];

          final isSelected = selectedStatus == item.status;

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              item.icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: Text(item.label),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : Colors.black.withOpacity(.07),
            ),
            onSelected: (_) {
              setState(() {
                selectedStatus = item.status;
              });
            },
          );
        },
      ),
    );
  }

  List<ImportedTransaction> _filterTransactions(
    List<ImportedTransaction> transactions,
  ) {
    if (selectedStatus == null) {
      return transactions;
    }

    return transactions
        .where((transaction) => transaction.status == selectedStatus)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // TRANSACTION TILE
  // ---------------------------------------------------------------------------

  Widget _buildTransactionTile(ImportedTransaction transaction) {
    final isDebit = transaction.type == ImportedTransactionType.debit;

    final isCredit = transaction.type == ImportedTransactionType.credit;

    final accentColor = isDebit
        ? Colors.red.shade600
        : isCredit
        ? Colors.green.shade600
        : Colors.blueGrey.shade600;

    final backgroundColor = isDebit
        ? Colors.red.withOpacity(.07)
        : isCredit
        ? Colors.green.withOpacity(.07)
        : Colors.blueGrey.withOpacity(.07);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openTransaction(transaction),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(.055)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.025),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildTransactionIcon(transaction, accentColor, backgroundColor),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _merchantName(transaction),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(transaction.transactionDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _buildStatusBadge(transaction.status),

                        if (_hasCategory(transaction)) ...[
                          const SizedBox(width: 6),
                          Flexible(child: _buildCategoryBadge(transaction)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formattedAmount(transaction),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.035),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right_rounded, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionIcon(
    ImportedTransaction transaction,
    Color accentColor,
    Color backgroundColor,
  ) {
    IconData icon;

    switch (transaction.type) {
      case ImportedTransactionType.debit:
        icon = Icons.arrow_upward_rounded;
        break;

      case ImportedTransactionType.credit:
        icon = Icons.arrow_downward_rounded;
        break;

      case ImportedTransactionType.unknown:
        icon = Icons.help_outline_rounded;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: accentColor, size: 21),
    );
  }

  String _formattedAmount(ImportedTransaction transaction) {
    final amount = transaction.amount.toStringAsFixed(0);

    switch (transaction.type) {
      case ImportedTransactionType.debit:
        return '- ₹$amount';

      case ImportedTransactionType.credit:
        return '+ ₹$amount';

      case ImportedTransactionType.unknown:
        return '₹$amount';
    }
  }

  // ---------------------------------------------------------------------------
  // BADGES
  // ---------------------------------------------------------------------------

  Widget _buildStatusBadge(ImportedTransactionStatus status) {
    late String label;
    late Color color;
    late IconData icon;

    switch (status) {
      case ImportedTransactionStatus.pending:
        label = 'Pending';
        color = Colors.orange;
        icon = Icons.pending_actions_rounded;
        break;

      case ImportedTransactionStatus.processed:
        label = 'Processed';
        color = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        break;

      case ImportedTransactionStatus.ignored:
        label = 'Ignored';
        color = Colors.grey;
        icon = Icons.remove_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(ImportedTransaction transaction) {
    // Currently ImportedTransaction does not contain
    // a category field.
    //
    // This widget is intentionally not used until category
    // information is actually available in the model.
    return const SizedBox.shrink();
  }

  bool _hasCategory(ImportedTransaction transaction) {
    // Category is not currently part of ImportedTransaction.
    // Keeping this false avoids inventing data or changing
    // the domain model just for presentation.
    return false;
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    switch (selectedStatus) {
      case ImportedTransactionStatus.pending:
        title = 'No pending transactions';
        subtitle =
            'New imported transactions waiting for review will appear here.';
        icon = Icons.pending_actions_rounded;
        break;

      case ImportedTransactionStatus.processed:
        title = 'No processed transactions';
        subtitle = 'Transactions converted into expenses will appear here.';
        icon = Icons.check_circle_outline_rounded;
        break;

      case ImportedTransactionStatus.ignored:
        title = 'No ignored transactions';
        subtitle = 'Transactions you choose to ignore will appear here.';
        icon = Icons.remove_circle_outline_rounded;
        break;

      case null:
        title = 'No imported transactions';
        subtitle = 'Import transaction SMS messages to see them here.';
        icon = Icons.sms_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            const Text(
              'Could not load transactions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            FilledButton(
              onPressed: () {
                ref.invalidate(importedTransactionsProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION / HELPERS
  // ---------------------------------------------------------------------------

  void _openTransaction(ImportedTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ImportedTransactionReviewScreen(transaction: transaction),
      ),
    );
  }

  String _merchantName(ImportedTransaction transaction) {
    if (transaction.merchant != null &&
        transaction.merchant!.trim().isNotEmpty) {
      return transaction.merchant!.trim();
    }

    if (transaction.upiId != null && transaction.upiId!.trim().isNotEmpty) {
      return transaction.upiId!.trim();
    }

    if (transaction.bankName != null &&
        transaction.bankName!.trim().isNotEmpty) {
      return transaction.bankName!.trim();
    }

    return 'UPI Transaction';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} • '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
