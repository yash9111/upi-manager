import 'package:hive/hive.dart';
import 'package:upi_tracker/features/category/domain/model/category_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/hive_boxes.dart';

class CategoryRepository {
  final Box<CategoryModel> _box = Hive.box<CategoryModel>(HiveBoxes.categories);

  List<CategoryModel> getCategories() {
    return _box.values.toList();
  }

  Future<void> seedDefaults() async {
    if (_box.isNotEmpty) return;

    const defaults = ['Food', 'Travel', 'Shopping', 'Bills', 'Entertainment'];

    for (final category in defaults) {
      final item = CategoryModel(
        id: const Uuid().v4(),
        name: category,
        isDefault: true,
      );

      await _box.put(item.id, item);
    }
  }

  Future<void> addCategory(String name) async {
    final exists = _box.values.any(
      (e) => e.name.toLowerCase() == name.trim().toLowerCase(),
    );

    if (exists) return;

    final category = CategoryModel(
      id: const Uuid().v4(),
      name: name.trim(),
      isDefault: false,
    );

    await _box.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }
}
