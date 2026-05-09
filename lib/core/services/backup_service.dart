import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/expenses/domain/models/expense_model.dart';
import '../constants/hive_boxes.dart';
import '../models/import_result_model.dart';

class BackupService {
  BackupService._();

static Future<void> exportData() async {
  final expenseBox =
      Hive.box<ExpenseModel>(
    HiveBoxes.expenses,
  );

  final expenses =
      expenseBox.values.toList();

  final jsonData = expenses
      .map((expense) =>
          expense.toJson())
      .toList();

  final directory =
      await getTemporaryDirectory();

  final file = File(
    '${directory.path}/expense_backup.json',
  );

  await file.writeAsString(
    jsonEncode(jsonData),
  );

  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Expense Backup',
  );
}

  static Future<ImportResultModel>
      importData() async {
    try {
      final result =
          await FilePicker
              .pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'json',
        ],
      );

      if (result == null) {
        return ImportResultModel(
          importedCount: 0,
          skippedCount: 0,
          success: false,
          message:
              'Import cancelled',
        );
      }

      final path =
          result.files.single.path;

      if (path == null) {
        return ImportResultModel(
          importedCount: 0,
          skippedCount: 0,
          success: false,
          message:
              'Invalid file path',
        );
      }

      final file = File(path);

      final content =
          await file.readAsString();

      final decoded =
          jsonDecode(content);

      if (decoded is! List) {
        return ImportResultModel(
          importedCount: 0,
          skippedCount: 0,
          success: false,
          message:
              'Invalid backup format',
        );
      }

      final expenseBox =
          Hive.box<ExpenseModel>(
        HiveBoxes.expenses,
      );

      int importedCount = 0;

      int skippedCount = 0;

      for (final item in decoded) {
        try {
          final expense =
              ExpenseModel.fromJson(
            item,
          );

          final alreadyExists =
              expenseBox.containsKey(
            expense.id,
          );

          if (alreadyExists) {
            skippedCount++;
            continue;
          }

          await expenseBox.put(
            expense.id,
            expense,
          );

          importedCount++;
        } catch (_) {
          skippedCount++;
        }
      }

      return ImportResultModel(
        importedCount:
            importedCount,
        skippedCount:
            skippedCount,
        success: true,
        message:
            'Import completed',
      );
    } catch (_) {
      return ImportResultModel(
        importedCount: 0,
        skippedCount: 0,
        success: false,
        message:
            'Failed to import backup',
      );
    }
  }
}