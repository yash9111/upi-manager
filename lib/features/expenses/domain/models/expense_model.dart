import 'package:hive/hive.dart';

import '../../../splits/domain/models/split_participant_model.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double totalAmount;

  @HiveField(2)
  final double myShare;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String note;

  @HiveField(5)
  final bool isShared;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final List<SplitParticipantModel> participants;

  ExpenseModel({
    required this.id,
    required this.totalAmount,
    required this.myShare,
    required this.category,
    required this.note,
    required this.isShared,
    required this.createdAt,
    required this.participants,
  });
}