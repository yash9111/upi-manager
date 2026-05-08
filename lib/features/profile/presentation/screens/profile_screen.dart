import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upi_tracker/features/profile/presentation/provider/saved_people_provider.dart';

import '../widgets/add_person_dialog.dart';
import '../widgets/saved_person_tile.dart';

class ProfileScreen
    extends ConsumerWidget {
  const ProfileScreen({
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return const AddPersonDialog();
            },
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              'Saved People',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Expanded(
              child: people.isEmpty
                  ? const Center(
                      child: Text(
                        'No saved people',
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          people.length,
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final person =
                            people[
                                index];

                        return SavedPersonTile(
                          name:
                              person.name,
                          onTap: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}