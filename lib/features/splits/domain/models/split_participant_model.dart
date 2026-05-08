import 'package:hive/hive.dart';

part 'split_participant_model.g.dart';

@HiveType(typeId: 1)
class SplitParticipantModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final bool isSettled;

  SplitParticipantModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.isSettled,
  });
}