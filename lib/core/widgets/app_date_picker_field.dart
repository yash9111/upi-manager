import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDatePickerField
    extends StatelessWidget {
  final DateTime selectedDate;

  final VoidCallback onTap;

  const AppDatePickerField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month,
            ),

            const SizedBox(width: 12),

            Text(
              DateFormat(
                'dd MMM yyyy',
              ).format(selectedDate),
            ),
          ],
        ),
      ),
    );
  }
}