import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/profile/presentation/provider/saved_people_provider.dart';

import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class AddPersonDialog
    extends ConsumerStatefulWidget {
  const AddPersonDialog({
    super.key,
  });

  @override
  ConsumerState<AddPersonDialog>
      createState() =>
          _AddPersonDialogState();
}

class _AddPersonDialogState
    extends ConsumerState<
        AddPersonDialog> {
  final controller =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Text(
              'Add Person',
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
              controller: controller,
              hint: 'Enter name',
              prefixIcon:
                  const Icon(
                Icons.person,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            AppPrimaryButton(
              text: 'Save',
              onTap: savePerson,
            ),
          ],
        ),
      ),
    );
  }

Future<void> savePerson() async {
  final name =
      controller.text.trim();

  if (name.isEmpty) {
    return;
  }

  final success = await ref
      .read(
        savedPeopleProvider
            .notifier,
      )
      .addPerson(name);

  if (!mounted) return;

  if (!success) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Person already exists',
        ),
      ),
    );

    return;
  }

  Navigator.pop(context);
}
}