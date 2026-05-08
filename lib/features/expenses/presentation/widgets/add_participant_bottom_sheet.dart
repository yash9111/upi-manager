import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../presentation/providers/temp_participants_provider.dart';

class AddParticipantBottomSheet
    extends ConsumerStatefulWidget {
  const AddParticipantBottomSheet({
    super.key,
  });

  @override
  ConsumerState<AddParticipantBottomSheet>
      createState() =>
          _AddParticipantBottomSheetState();
}

class _AddParticipantBottomSheetState
    extends ConsumerState<
        AddParticipantBottomSheet> {
  final nameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom:
            MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Participant',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          AppTextField(
            controller: nameController,
            hint: 'Enter name',
            prefixIcon:
                const Icon(Icons.person),
          ),

          const SizedBox(height: 24),

          AppPrimaryButton(
            text: 'Add',
            onTap: addParticipant,
          ),
        ],
      ),
    );
  }

  void addParticipant() {
    final name =
        nameController.text.trim();

    if (name.isEmpty) return;

    ref
        .read(
          tempParticipantsProvider
              .notifier,
        )
        .addParticipant(name);

    Navigator.pop(context);
  }
}