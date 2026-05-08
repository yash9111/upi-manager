import 'package:flutter/material.dart';

class AnalyticsCard
    extends StatelessWidget {
  final String title;

  final String value;

  final Color color;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(
            24,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}