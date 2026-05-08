import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/models/saved_person_model.dart';

class SavedPeopleRepository {
  final Box<SavedPersonModel> _box =
      Hive.box<SavedPersonModel>(
    HiveBoxes.savedPeople,
  );

  List<SavedPersonModel> getPeople() {
    return _box.values.toList();
  }

  Future<void> addPerson(
    SavedPersonModel person,
  ) async {
    await _box.put(person.id, person);
  }
}