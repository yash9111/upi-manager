import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/saved_people_repository.dart';
import '../../domain/models/saved_person_model.dart';

final savedPeopleRepositoryProvider =
    Provider<SavedPeopleRepository>((ref) {
  return SavedPeopleRepository();
});

final savedPeopleProvider =
    StateNotifierProvider<
        SavedPeopleNotifier,
        List<SavedPersonModel>>((ref) {
  return SavedPeopleNotifier(
    ref.read(
      savedPeopleRepositoryProvider,
    ),
  );
});

class SavedPeopleNotifier
    extends StateNotifier<
        List<SavedPersonModel>> {
  final SavedPeopleRepository
      repository;

  SavedPeopleNotifier(this.repository)
      : super(repository.getPeople());

  void loadPeople() {
    state = repository.getPeople();
  }

  Future<bool> addPerson(
    String name,
  ) async {
    final normalizedName =
        name.trim().toLowerCase();

    final alreadyExists = state.any(
      (person) =>
          person.name
              .trim()
              .toLowerCase() ==
          normalizedName,
    );

    if (alreadyExists) {
      return false;
    }

    final person = SavedPersonModel(
      id: const Uuid().v4(),
      name: name.trim(),
    );

    await repository.addPerson(person);

    loadPeople();

    return true;
  }
}