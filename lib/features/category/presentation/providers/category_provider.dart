import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/category/domain/model/category_model.dart';

import '../../data/repositories/category_repository.dart';

final categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoriesProvider =
    StateNotifierProvider<
        CategoryNotifier,
        List<CategoryModel>>((ref) {
  return CategoryNotifier(
    ref.read(
      categoryRepositoryProvider,
    ),
  );
});

class CategoryNotifier
    extends StateNotifier<
        List<CategoryModel>> {
  final CategoryRepository
      repository;

  CategoryNotifier(this.repository)
      : super([]) {
    init();
  }

  Future<void> init() async {
    await repository.seedDefaults();

    state =
        repository.getCategories();
  }

  Future<void> addCategory(
    String name,
  ) async {
    await repository.addCategory(
      name,
    );

    state =
        repository.getCategories();
  }

  Future<void> deleteCategory(
    String id,
  ) async {
    await repository.deleteCategory(
      id,
    );

    state =
        repository.getCategories();
  }
}