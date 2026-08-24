import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/imported_transactions/data/services/imported_transaction_batch_service.dart';
import 'package:upi_tracker/features/imported_transactions/presentation/screens/bulk_import_review_screen.dart';

import '../providers/imported_transaction_provider.dart';
import 'imported_transactions_screen.dart';

class BulkSmsImportScreen extends ConsumerStatefulWidget {
  const BulkSmsImportScreen({super.key});

  @override
  ConsumerState<BulkSmsImportScreen> createState() =>
      _BulkSmsImportScreenState();
}

class _BulkSmsImportScreenState extends ConsumerState<BulkSmsImportScreen> {
  DateTime? startDate;
  DateTime? endDate;

  bool importing = false;

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: startDate ?? DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      startDate = picked;

      // If the existing end date is before the new start date,
      // clear it so the user has to select a valid range.
      if (endDate != null && picked.isAfter(endDate!)) {
        endDate = null;
      }
    });
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: endDate ?? startDate ?? DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      endDate = picked;
    });
  }

  Future<void> _import() async {
    if (startDate == null || endDate == null) {
      _showMessage('Select both dates first.');
      return;
    }

    if (startDate!.isAfter(endDate!)) {
      _showMessage('Start date cannot be after end date.');
      return;
    }

    setState(() {
      importing = true;
    });

    try {
      final result = await ref
          .read(importedTransactionBatchServiceProvider)
          .importRange(
            startDate: DateTime(
              startDate!.year,
              startDate!.month,
              startDate!.day,
            ),
            endDate: DateTime(
              endDate!.year,
              endDate!.month,
              endDate!.day,
              23,
              59,
              59,
              999,
            ),
          );

      if (!mounted) {
        return;
      }

      setState(() {
        importing = false;
      });

      await _showImportResult(result);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        importing = false;
      });

      _showMessage('Could not import SMS: $e');
    }
  }

  Future<void> _showImportResult(
  BatchImportResult result,
) async {
  final shouldReview =
      await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return _ImportSummarySheet(
        result: result,
      );
    },
  );

  if (!mounted) {
    return;
  }

  if (shouldReview == true) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BulkImportReviewScreen(
          transactionIds:
              result.importedTransactionIds,
        ),
      ),
    );
  }
}

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SMS Import',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeveloperCard(),

            const SizedBox(height: 30),

            const Text(
              'Select SMS range',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            Text(
              'Scan messages from a specific date range. '
              'Recognized transactions will be added to '
              'your review queue.',
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.45,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            _dateCard(
              title: 'Start Date',
              date: startDate,
              icon: Icons.calendar_today_rounded,
              onTap: _selectStartDate,
            ),

            const SizedBox(height: 12),

            _dateCard(
              title: 'End Date',
              date: endDate,
              icon: Icons.event_rounded,
              onTap: _selectEndDate,
            ),

            const SizedBox(height: 28),

            if (startDate != null && endDate != null) _buildSelectedRange(),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton.icon(
                onPressed: importing ? null : _import,
                icon: importing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync_rounded),
                label: Text(
                  importing ? 'Scanning SMS...' : 'Scan & Import SMS',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                'Existing transactions will not be imported again.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.indigo.withOpacity(.10),
            ),
            child: const Icon(Icons.sms_outlined, color: Colors.indigo),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMS Import Tool',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 3),
                Text(
                  'Import transactions for manual review',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'DEV',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedRange() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range_rounded,
            size: 20,
            color: Colors.indigo.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_formatDate(startDate!)}  →  ${_formatDate(endDate!)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCard({
    required String title,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasDate = date != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(.08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: Colors.indigo.shade600, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasDate ? _formatDate(date) : 'Select date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: hasDate ? Colors.black87 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _ImportSummarySheet extends StatelessWidget {
  final BatchImportResult result;

  const _ImportSummarySheet({required this.result});

  @override
  Widget build(BuildContext context) {
    final hasImported = result.imported > 0;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 22),

            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasImported
                    ? Colors.green.withOpacity(.10)
                    : Colors.grey.withOpacity(.10),
              ),
              child: Icon(
                hasImported ? Icons.check_rounded : Icons.info_outline_rounded,
                color: hasImported ? Colors.green : Colors.grey.shade700,
                size: 30,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              hasImported ? 'Import complete' : 'Import finished',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 6),

            Text(
              hasImported
                  ? '${result.imported} new transaction'
                        '${result.imported == 1 ? '' : 's'} ready for review.'
                  : 'No new transactions were added.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'SMS scanned',
                    value: result.totalSms,
                    icon: Icons.sms_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Candidates',
                    value: result.candidateSms,
                    icon: Icons.filter_alt_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'New',
                    value: result.imported,
                    icon: Icons.add_circle_outline_rounded,
                    valueColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Duplicates',
                    value: result.duplicates,
                    icon: Icons.copy_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Parsed',
                    value: result.parsed,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Failed',
                    value: result.failed,
                    icon: Icons.error_outline_rounded,
                    valueColor: result.failed > 0 ? Colors.red : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (hasImported)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text(
                    'Review Transactions',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

            if (hasImported) const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(
                  hasImported ? 'Review Later' : 'Done',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: Colors.grey.shade600),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
