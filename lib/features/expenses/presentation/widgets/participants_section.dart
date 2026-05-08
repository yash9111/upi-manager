import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/temp_participants_provider.dart';
import 'add_participant_bottom_sheet.dart';
import 'participant_tile.dart';

class ParticipantsSection
    extends ConsumerWidget {
  const ParticipantsSection({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final participants = ref.watch(
      tempParticipantsProvider,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Participants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    return const AddParticipantBottomSheet();
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Add',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (participants.isEmpty)
          const Text(
            'No participants added',
          ),

        ...participants.map((participant) {
          return ParticipantTile(
            name: participant.name,
            amount: participant.amount,
            onRemove: () {
              ref
                  .read(
                    tempParticipantsProvider
                        .notifier,
                  )
                  .removeParticipant(
                    participant.id,
                  );
            },
          );
        }),
      ],
    );
  }
}