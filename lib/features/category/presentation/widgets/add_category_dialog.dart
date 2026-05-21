import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../category/presentation/providers/category_provider.dart';

class AddCategoryDialog
    extends ConsumerStatefulWidget {
  const AddCategoryDialog({
    super.key,
  });

  @override
  ConsumerState<
      AddCategoryDialog> createState() =>
      _AddCategoryDialogState();
}

class _AddCategoryDialogState
    extends ConsumerState<
        AddCategoryDialog> {
  final controller =
      TextEditingController();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Dialog(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Text(
              'Add Category',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            AppTextField(
              controller:
                  controller,
              hint:
                  'Category name',
            ),

            const SizedBox(
              height: 20,
            ),

            AppPrimaryButton(
              text:
                  'Create Category',
              onTap: save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    final name =
        controller.text.trim();

    if (name.isEmpty) return;

    await ref
        .read(
          categoriesProvider
              .notifier,
        )
        .addCategory(name);

    if (!mounted) return;

    Navigator.pop(context);
  }
}