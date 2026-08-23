import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/imported_transaction_provider.dart';

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
    });
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: endDate ?? DateTime.now(),
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

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Import Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SMS scanned: ${result.totalSms}'),
              const SizedBox(height: 8),
              Text(
                'Possible transactions: '
                '${result.candidateSms}',
              ),
              const SizedBox(height: 8),
              Text(
                'Successfully parsed: '
                '${result.parsed}',
              ),
              const SizedBox(height: 8),
              Text(
                'New transactions: '
                '${result.imported}',
              ),
              const SizedBox(height: 8),
              Text(
                'Already imported: '
                '${result.duplicates}',
              ),
              const SizedBox(height: 8),
              Text(
                'Could not parse: '
                '${result.failed}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Import')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Developer Import Tool',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Select SMS range',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'All SMS messages in this range will be '
              'parsed. Only recognized transactions '
              'will be added for review.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            _dateCard(
              title: 'Start Date',
              date: startDate,
              onTap: _selectStartDate,
            ),

            const SizedBox(height: 14),

            _dateCard(title: 'End Date', date: endDate, onTap: _selectEndDate),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: importing ? null : _import,
                icon: importing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined),
                label: Text(importing ? 'Importing...' : 'Import SMS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateCard({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date == null
                        ? 'Select date'
                        : '${date.day.toString().padLeft(2, '0')}/'
                              '${date.month.toString().padLeft(2, '0')}/'
                              '${date.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
