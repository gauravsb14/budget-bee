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

  // 👇 instead of one budget, store multiple month-wise
  @HiveField(3)
  Map<String, double> monthlyBudgets;

  @HiveField(4)
  double spent; // this can stay, or you can also make it month-wise later

  SubCategory({
    required this.id,
    required this.parentCategoryId,
    required this.name,
    Map<String, double>? monthlyBudgets,
    this.spent = 0,
  }) : monthlyBudgets =
           monthlyBudgets ??
           {for (int m = 1; m <= 12; m++) '${DateTime.now().year}-$m': 0.0};
}
