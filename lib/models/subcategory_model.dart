import 'package:hive/hive.dart';
part 'subcategory_model.g.dart';

@HiveType(typeId: 2)
class SubCategory extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int parentCategoryId;

  @HiveField(2)
  String name;

  @HiveField(3)
  double monthlyBudget;

  @HiveField(4)
  double spent;

  SubCategory({
    required this.id,
    required this.parentCategoryId,
    required this.name,
    required this.monthlyBudget,
    this.spent = 0,
  });
}
