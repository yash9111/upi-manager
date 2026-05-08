import 'package:hive/hive.dart';

part 'saved_person_model.g.dart';

@HiveType(typeId: 2)
class SavedPersonModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  SavedPersonModel({
    required this.id,
    required this.name,
  });
}