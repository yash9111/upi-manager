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
        title:GestureDetector(
          child: const Text(
          'Imported Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BulkSmsImportScreen(),
              ),
            );
          },
        )
        
         
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(error),
        data: (transactions) {
          final filtered = _filterTransactions(transactions);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(importedTransactionsProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(transactions)),

                SliverToBoxAdapter(child: _buildFilterChips(transactions)),

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

  Widget _buildHeader(List<ImportedTransaction> transactions) {
    final pending = transactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.pending,
        )
        .length;

    final processed = transactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.processed,
        )
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(child: _headerStat('Pending', pending.toString())),
            _verticalDivider(),
            Expanded(child: _headerStat('Processed', processed.toString())),
            _verticalDivider(),
            Expanded(
              child: _headerStat('Total', transactions.length.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 40, width: 1, color: Colors.white24);
  }

  Widget _buildFilterChips(List<ImportedTransaction> transactions) {
    final statuses = [
      (label: 'All', status: null),
      (label: 'Pending', status: ImportedTransactionStatus.pending),
      (label: 'Processed', status: ImportedTransactionStatus.processed),
      (label: 'Ignored', status: ImportedTransactionStatus.ignored),
    ];

    return SizedBox(
      height: 58,
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
            label: Text(item.label),
            onSelected: (_) {
              setState(() {
                selectedStatus = item.status;
              });
            },
            showCheckmark: false,
            avatar: isSelected
                ? const Icon(Icons.check_rounded, size: 17)
                : null,
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

  Widget _buildTransactionTile(ImportedTransaction transaction) {
    final isDebit = transaction.type == ImportedTransactionType.debit;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openTransaction(transaction),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(.05)),
          ),
          child: Row(
            children: [
              _buildTransactionIcon(transaction),

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
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _formatDate(transaction.transactionDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    _buildStatusBadge(transaction.status),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isDebit ? '-' : '+'} ₹${transaction.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDebit ? Colors.black87 : Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionIcon(ImportedTransaction transaction) {
    final isDebit = transaction.type == ImportedTransactionType.debit;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDebit
            ? Colors.red.withOpacity(.08)
            : Colors.green.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        color: isDebit ? Colors.red.shade600 : Colors.green.shade600,
      ),
    );
  }

  Widget _buildStatusBadge(ImportedTransactionStatus status) {
    late String label;
    late Color color;
    late IconData icon;

    switch (status) {
      case ImportedTransactionStatus.pending:
        label = 'Pending review';
        color = Colors.orange;
        icon = Icons.pending_actions_rounded;
        break;

      case ImportedTransactionStatus.processed:
        label = 'Processed';
        color = Colors.green;
        icon = Icons.check_circle_outline;
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
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;

    switch (selectedStatus) {
      case ImportedTransactionStatus.pending:
        title = 'No pending transactions';
        subtitle =
            'New imported transactions waiting for review will appear here.';
        break;

      case ImportedTransactionStatus.processed:
        title = 'No processed transactions';
        subtitle = 'Transactions converted into expenses will appear here.';
        break;

      case ImportedTransactionStatus.ignored:
        title = 'No ignored transactions';
        subtitle = 'Transactions you choose to ignore will appear here.';
        break;

      case null:
        title = 'No imported transactions';
        subtitle = 'Import transaction SMS messages to see them here.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
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
      return transaction.merchant!;
    }

    if (transaction.upiId != null && transaction.upiId!.trim().isNotEmpty) {
      return transaction.upiId!;
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
