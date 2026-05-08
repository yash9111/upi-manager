import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/profile/presentation/provider/saved_people_provider.dart';

import '../providers/temp_participants_provider.dart';

class SavedPeopleSection
    extends ConsumerWidget {
  const SavedPeopleSection({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final people = ref.watch(
      savedPeopleProvider,
    );

    if (people.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved People',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: people.map((person) {
            return GestureDetector(
              onTap: () {
                ref
                    .read(
                      tempParticipantsProvider
                          .notifier,
                    )
                    .addParticipant(
                      person.name,
                    );
              },
              child: Chip(
                label: Text(
                  person.name,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}