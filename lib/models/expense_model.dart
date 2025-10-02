import 'package:hive/hive.dart';
part 'expense_model.g.dart';

@HiveType(typeId: 3)
class Expense extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int subCategoryId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String note;

  @HiveField(4)
  DateTime date;

  Expense({
    required this.id,
    required this.subCategoryId,
    required this.amount,
    this.note = '',
    required this.date,
  });
}
