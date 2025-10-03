import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/category_model.dart';
import '../../../models/subcategory_model.dart';
import '../widgets/category_tile.dart';
import '../../shared/widgets/top_summary.dart';
import '../../shared/widgets/top_bar.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final categoryBox = Hive.box<Category>('categories');
    final subBox = Hive.box<SubCategory>('subcategories');

    return ValueListenableBuilder(
      valueListenable: categoryBox.listenable(),
      builder: (context, Box<Category> box, _) {
        final categories = box.values.toList();

        // --- Calculate Top Summary for selected month/year ---
        double totalBudget = 0;
        double totalSpent = 0;

        for (var cat in categories) {
          final subs = subBox.values
              .where((s) => s.parentCategoryId == cat.id)
              .toList();

          totalBudget += subs.fold(0, (sum, s) => sum + s.monthlyBudget);
          totalSpent += subs.fold(0, (sum, s) => sum + s.spent);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Budget",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 35, 48, 124),
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 138, 184, 179),
            elevation: 0, // flush with TopBar
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddCategoryDialog(context),
            backgroundColor: const Color.fromARGB(255, 138, 184, 179),
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              // --- TopBar for Year/Month selection ---
              Container(
                color: const Color.fromARGB(255, 138, 184, 179),
                padding: const EdgeInsets.symmetric(
                  // vertical: 8,
                  horizontal: 12,
                ),
                child: TopBar(
                  selectedYear: selectedYear,
                  selectedMonth: selectedMonth,
                  onYearChanged: (year) {
                    setState(() => selectedYear = year);
                  },
                  onMonthChanged: (month) {
                    setState(() => selectedMonth = month);
                  },
                ),
              ),

              // --- Top Summary ---
              Container(
                color: const Color.fromARGB(255, 138, 184, 179),
                // padding: const EdgeInsets.symmetric(vertical: 8),
                child: TopSummary(
                  totalBudget: totalBudget,
                  totalSpent: totalSpent,
                  month: selectedMonth,
                  year: selectedYear,
                  textColor: Colors.white,
                ),
              ),

              // const SizedBox(height: 8),

              // --- Category Tiles ---
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryTile(category: categories[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Add Main Category ---
  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryBox = Hive.box<Category>('categories');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              categoryBox.add(
                Category(id: DateTime.now().millisecondsSinceEpoch, name: name),
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
