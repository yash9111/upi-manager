import 'package:hive_flutter/hive_flutter.dart';

import '../../features/expenses/domain/models/expense_model.dart';
import '../../features/profile/domain/models/saved_person_model.dart';
import '../../features/splits/domain/models/split_participant_model.dart';
import '../constants/hive_boxes.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(
      ExpenseModelAdapter(),
    );

    Hive.registerAdapter(
      SplitParticipantModelAdapter(),
    );

    Hive.registerAdapter(
      SavedPersonModelAdapter(),
    );

    await Hive.openBox<ExpenseModel>(
      HiveBoxes.expenses,
    );

    await Hive.openBox<SavedPersonModel>(
      HiveBoxes.savedPeople,
    );
  }
}