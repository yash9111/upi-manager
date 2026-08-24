import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/imported_transaction.dart';
import '../providers/imported_transaction_provider.dart';
import 'imported_transaction_review_screen.dart';

class BulkImportReviewScreen extends ConsumerStatefulWidget {
  final List<String> transactionIds;

  const BulkImportReviewScreen({super.key, required this.transactionIds});

  @override
  ConsumerState<BulkImportReviewScreen> createState() =>
      _BulkImportReviewScreenState();
}

class _BulkImportReviewScreenState
    extends ConsumerState<BulkImportReviewScreen> {
  final TextEditingController _searchController = TextEditingController();

  ImportedTransactionStatus? _selectedStatus =
      ImportedTransactionStatus.pending;

  ImportedTransactionType? _selectedType;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _newestFirst = true;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _loadBulkTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // final repository =
  //     ref.read(importedTransactionRepositoryProvider);
  List<ImportedTransaction> _bulkTransactions = [];

  bool _isLoading = true;
  Object? _loadError;

  Future<void> _loadBulkTransactions() async {
    try {
      final repository = ref.read(importedTransactionRepositoryProvider);

      final allTransactions = await repository.getAll();

      final ids = widget.transactionIds.toSet();

      final transactions = allTransactions
          .where((transaction) => ids.contains(transaction.id))
          .toList();

      transactions.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _bulkTransactions = transactions;
        _isLoading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = e;
      });
    }
  }

  List<ImportedTransaction> get _filteredTransactions {
    final search = _searchController.text.trim().toLowerCase();

    final result = _bulkTransactions.where((transaction) {
      // ------------------------------------------------------------
      // STATUS
      // ------------------------------------------------------------

      if (_selectedStatus != null && transaction.status != _selectedStatus) {
        return false;
      }

      // ------------------------------------------------------------
      // TYPE
      // ------------------------------------------------------------

      if (_selectedType != null && transaction.type != _selectedType) {
        return false;
      }

      // ------------------------------------------------------------
      // DATE
      // ------------------------------------------------------------

      if (_startDate != null) {
        final start = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );

        if (transaction.transactionDate.isBefore(start)) {
          return false;
        }
      }

      if (_endDate != null) {
        final end = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
          999,
        );

        if (transaction.transactionDate.isAfter(end)) {
          return false;
        }
      }

      // ------------------------------------------------------------
      // SEARCH
      // ------------------------------------------------------------

      if (search.isNotEmpty) {
        final searchableText = [
          transaction.merchant,
          transaction.upiId,
          transaction.bankName,
          transaction.accountNumber,
          transaction.referenceNumber,
          transaction.rawSms,
        ].whereType<String>().join(' ').toLowerCase();

        if (!searchableText.contains(search)) {
          return false;
        }
      }

      return true;
    }).toList();

    result.sort((a, b) {
      final comparison = a.transactionDate.compareTo(b.transactionDate);

      return _newestFirst ? -comparison : comparison;
    });

    return result;
  }

  int get _pendingCount {
    return _bulkTransactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.pending,
        )
        .length;
  }

  int get _debitCount {
    return _bulkTransactions
        .where(
          (transaction) => transaction.type == ImportedTransactionType.debit,
        )
        .length;
  }

  int get _creditCount {
    return _bulkTransactions
        .where(
          (transaction) => transaction.type == ImportedTransactionType.credit,
        )
        .length;
  }

  double get _pendingDebitAmount {
    return _bulkTransactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.pending &&
              transaction.type == ImportedTransactionType.debit,
        )
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bulk Review')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load this import batch.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _loadError = null;
                  });

                  _loadBulkTransactions();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final transactions = _filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bulk Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: _newestFirst ? 'Oldest first' : 'Newest first',
            onPressed: () {
              setState(() {
                _newestFirst = !_newestFirst;
              });
            },
            icon: Icon(
              _newestFirst
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(),
             _buildBulkActions(),
          _buildSearch(),
          _buildStatusFilters(),
          _buildTypeFilters(),
          _buildDateFilter(),
          const SizedBox(height: 4),
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : _buildTransactionList(transactions),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(.75),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bulk Import',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${_bulkTransactions.length} transactions imported',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _summaryStat(
                  label: 'Pending',
                  value: _pendingCount.toString(),
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _summaryStat(
                  label: 'Debit',
                  value: _debitCount.toString(),
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _summaryStat(
                  label: 'Credit',
                  value: _creditCount.toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 19,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Pending debit amount',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Text(
                  '₹${_pendingDebitAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 34, width: 1, color: Colors.white24);
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search merchant, bank, UPI ID or SMS...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
  // ---------------------------------------------------------------------------
  // BULK ACTIONS
  // ---------------------------------------------------------------------------

Widget _buildBulkActions() {
  final hasPendingCredits =
      _pendingCreditCount > 0;

  final hasIgnored =
      _ignoredCount > 0;

  if (!hasPendingCredits && !hasIgnored) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(
      20,
      0,
      20,
      10,
    ),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(.05),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(.08),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Bulk Actions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            'Quickly clean up transactions that '
            'do not need individual review.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (hasPendingCredits)
                OutlinedButton.icon(
                  onPressed:
                      _ignoreAllPendingCredits,
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 17,
                  ),
                  label: Text(
                    'Ignore $_pendingCreditCount '
                    '${_pendingCreditCount == 1 ? 'credit' : 'credits'}',
                  ),
                ),

              if (hasIgnored)
                TextButton.icon(
                  onPressed:
                      _resetIgnoredTransactions,
                  icon: const Icon(
                    Icons.undo_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'Restore ignored',
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}


  // ---------------------------------------------------------------------------
  // STATUS FILTER
  // ---------------------------------------------------------------------------

  Widget _buildStatusFilters() {
    return _horizontalFilter(
      [
        (
          label: 'Pending',
          icon: Icons.pending_actions_rounded,
          value: ImportedTransactionStatus.pending,
        ),
        (
          label: 'Processed',
          icon: Icons.check_circle_outline_rounded,
          value: ImportedTransactionStatus.processed,
        ),
        (
          label: 'Ignored',
          icon: Icons.remove_circle_outline_rounded,
          value: ImportedTransactionStatus.ignored,
        ),
        (label: 'All', icon: Icons.all_inclusive_rounded, value: null),
      ],
      (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
      _selectedStatus,
    );
  }

  // ---------------------------------------------------------------------------
  // TYPE FILTER
  // ---------------------------------------------------------------------------

  Widget _buildTypeFilters() {
    return _horizontalFilter(
      [
        (label: 'All Types', icon: Icons.swap_vert_rounded, value: null),
        (
          label: 'Debit',
          icon: Icons.arrow_upward_rounded,
          value: ImportedTransactionType.debit,
        ),
        (
          label: 'Credit',
          icon: Icons.arrow_downward_rounded,
          value: ImportedTransactionType.credit,
        ),
      ],
      (value) {
        setState(() {
          _selectedType = value;
        });
      },
      _selectedType,
    );
  }

  Widget _horizontalFilter<T>(
    List<({String label, IconData icon, T value})> items,
    void Function(T value) onSelected,
    T selected,
  ) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];

          final isSelected = item.value == selected;

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(item.icon, size: 16),
            label: Text(item.label),
            onSelected: (_) {
              onSelected(item.value);
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DATE FILTER
  // ---------------------------------------------------------------------------

  Widget _buildDateFilter() {
    final hasDateFilter = _startDate != null || _endDate != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickDateRange,
              icon: const Icon(Icons.date_range_rounded, size: 18),
              label: Text(
                hasDateFilter ? _formatDateRange() : 'Filter by date',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (hasDateFilter) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Clear date filter',
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _startDate = picked.start;
      _endDate = picked.end;
    });
  }

  String _formatDateRange() {
    if (_startDate == null) {
      return 'Before ${_formatDate(_endDate!)}';
    }

    if (_endDate == null) {
      return 'From ${_formatDate(_startDate!)}';
    }

    return '${_formatDate(_startDate!)}'
        ' - '
        '${_formatDate(_endDate!)}';
  }

  // ---------------------------------------------------------------------------
  // TRANSACTION LIST
  // ---------------------------------------------------------------------------

  Widget _buildTransactionList(List<ImportedTransaction> transactions) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildTransactionTile(transactions[index]);
      },
    );
  }

  Widget _buildTransactionTile(ImportedTransaction transaction) {
    final isDebit = transaction.type == ImportedTransactionType.debit;

    final amountText =
        '${isDebit ? '-' : '+'} ₹'
        '${transaction.amount.toStringAsFixed(2)}';

    final amountColor = isDebit ? Colors.red : Colors.green;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openTransaction(transaction),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(.05)),
          ),
          child: Row(
            children: [
              _transactionIcon(transaction),

              const SizedBox(width: 13),

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

                    Text(
                      _formatTransactionDate(transaction.transactionDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        _statusBadge(transaction.status),
                        const SizedBox(width: 6),
                        _typeBadge(transaction.type),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Text(
                amountText,
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionIcon(ImportedTransaction transaction) {
    final isDebit = transaction.type == ImportedTransactionType.debit;

    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: (isDebit ? Colors.red : Colors.green).withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        color: isDebit ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _statusBadge(ImportedTransactionStatus status) {
    late String label;
    late Color color;

    switch (status) {
      case ImportedTransactionStatus.pending:
        label = 'Pending';
        color = Colors.orange;
        break;

      case ImportedTransactionStatus.processed:
        label = 'Processed';
        color = Colors.green;
        break;

      case ImportedTransactionStatus.ignored:
        label = 'Ignored';
        color = Colors.grey;
        break;
    }

    return _badge(label, color);
  }

  Widget _typeBadge(ImportedTransactionType type) {
    switch (type) {
      case ImportedTransactionType.debit:
        return _badge('Debit', Colors.red);

      case ImportedTransactionType.credit:
        return _badge('Credit', Colors.green);

      case ImportedTransactionType.unknown:
        return _badge('Unknown', Colors.grey);
    }
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.filter_list_off_rounded,
                  size: 34,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'No matching transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 8),

              Text(
                'Try changing the filters or search term.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),

              const SizedBox(height: 18),

              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = ImportedTransactionStatus.pending;
      _selectedType = null;
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
  }

  // ---------------------------------------------------------------------------
  // BULK ACTIONS
  // ---------------------------------------------------------------------------

  int get _pendingCreditCount {
    return _bulkTransactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.pending &&
              transaction.type == ImportedTransactionType.credit,
        )
        .length;
  }

  int get _ignoredCount {
    return _bulkTransactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.ignored,
        )
        .length;
  }

  Future<void> _ignoreAllPendingCredits() async {
    final credits = _bulkTransactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.pending &&
              transaction.type == ImportedTransactionType.credit,
        )
        .toList();

    if (credits.isEmpty) {
      return;
    }

    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ignore credit transactions?'),
          content: Text(
            '${credits.length} credit '
            '${credits.length == 1 ? 'transaction' : 'transactions'} '
            'will be marked as ignored.\n\n'
            'Credits are kept for reference and will not be '
            'converted into expenses.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Ignore Credits'),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true) {
      return;
    }

    try {
      final repository = ref.read(importedTransactionRepositoryProvider);

      for (final transaction in credits) {
        await repository.update(
          transaction.copyWith(status: ImportedTransactionStatus.ignored),
        );
      }

      await _loadBulkTransactions();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${credits.length} credit '
            '${credits.length == 1 ? 'transaction' : 'transactions'} '
            'ignored.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to ignore credit transactions.')),
      );
    }
  }

  Future<void> _resetIgnoredTransactions() async {
    final ignored = _bulkTransactions
        .where(
          (transaction) =>
              transaction.status == ImportedTransactionStatus.ignored,
        )
        .toList();

    if (ignored.isEmpty) {
      return;
    }

    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Move back to pending?'),
          content: Text(
            '${ignored.length} ignored '
            '${ignored.length == 1 ? 'transaction' : 'transactions'} '
            'will become pending again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Move to Pending'),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true) {
      return;
    }

    try {
      final repository = ref.read(importedTransactionRepositoryProvider);

      for (final transaction in ignored) {
        await repository.update(
          transaction.copyWith(status: ImportedTransactionStatus.pending),
        );
      }

      await _loadBulkTransactions();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${ignored.length} '
            '${ignored.length == 1 ? 'transaction' : 'transactions'} '
            'moved back to pending.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update transactions.')),
      );
    }
  }
  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------

  Future<void> _openTransaction(ImportedTransaction transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ImportedTransactionReviewScreen(transaction: transaction),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadBulkTransactions();
  }
  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

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

  String _formatTransactionDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} • '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
