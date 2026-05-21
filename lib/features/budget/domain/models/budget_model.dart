import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 4)
class BudgetModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final int month;

  @HiveField(4)
  final int year;

  @HiveField(5)
  final DateTime createdAt;

  const BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
  });
}