import 'package:hive/hive.dart';

import '../models/imported_transaction_model.dart';
import '../../domain/models/imported_transaction.dart';

class ImportedTransactionRepository {
  static const String boxName = 'imported_transactions';

  Future<Box<ImportedTransactionModel>> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<ImportedTransactionModel>(boxName);
    }

    return Hive.openBox<ImportedTransactionModel>(boxName);
  }

  Future<List<ImportedTransaction>> getAll() async {
    final box = await _box();

    return box.values.map((model) => model.toDomain()).toList();
  }

  Future<bool> exists(String id) async {
    final box = await _box();

    return box.containsKey(id);
  }

  Future<void> save(ImportedTransaction transaction) async {
    final box = await _box();

    if (box.containsKey(transaction.id)) {
      return;
    }

    await box.put(
      transaction.id,
      ImportedTransactionModel.fromDomain(transaction),
    );
  }

  Future<void> update(ImportedTransaction transaction) async {
    final box = await _box();

    await box.put(
      transaction.id,
      ImportedTransactionModel.fromDomain(transaction),
    );

  //  await box.clear();
  }

  Future<void> delete(String id) async {
    final box = await _box();

    await box.delete(id);
  }
}
