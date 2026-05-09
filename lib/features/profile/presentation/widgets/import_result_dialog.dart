import 'package:flutter/material.dart';

import '../../../../core/models/import_result_model.dart';

class ImportResultDialog
    extends StatelessWidget {
  final ImportResultModel result;

  const ImportResultDialog({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              result.success
                  ? Icons.check_circle
                  : Icons.error,
              size: 70,
              color: result.success
                  ? Colors.green
                  : Colors.red,
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              result.message,
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 24,
            ),

            if (result.success)
              Column(
                children: [
                  buildRow(
                    'Imported',
                    '${result.importedCount}',
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  buildRow(
                    'Skipped',
                    '${result.skippedCount}',
                  ),
                ],
              ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  'Done',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(
    String title,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}