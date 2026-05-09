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
  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'totalAmount': totalAmount,
    'myShare': myShare,
    'category': category,
    'note': note,
    'isShared': isShared,
    'createdAt':
        createdAt.toIso8601String(),
    'participants': participants
        .map((e) => e.toJson())
        .toList(),
  };
}

factory ExpenseModel.fromJson(
  Map<String, dynamic> json,
) {
  return ExpenseModel(
    id: json['id'],
    totalAmount:
        (json['totalAmount'] as num)
            .toDouble(),
    myShare:
        (json['myShare'] as num)
            .toDouble(),
    category: json['category'],
    note: json['note'],
    isShared: json['isShared'],
    createdAt: DateTime.parse(
      json['createdAt'],
    ),
    participants:
        (json['participants']
                as List)
            .map(
              (e) =>
                  SplitParticipantModel
                      .fromJson(e),
            )
            .toList(),
  );
}
}