import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/category_model.dart';
import '../../../models/subcategory_model.dart';
import '../widgets/category_tile.dart';
import '../../shared/widgets/top_summary.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryBox = Hive.box<Category>('categories');
    final subBox = Hive.box<SubCategory>('subcategories');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Bee"),
        backgroundColor: const Color.fromARGB(255, 138, 184, 179),
        // foregroundColor: Colors.white,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: const Color.fromARGB(255, 138, 184, 179),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: categoryBox.listenable(),
        builder: (context, Box<Category> box, _) {
          final categories = box.values.toList();

          // --- Calculate Top Summary ---
          double totalBudget = 0;
          double totalSpent = 0;
          for (var cat in categories) {
            final subs = subBox.values
                .where((s) => s.parentCategoryId == cat.id)
                .toList();
            totalBudget += subs.fold(0, (sum, s) => sum + s.monthlyBudget);
            totalSpent += subs.fold(0, (sum, s) => sum + s.spent);
          }

          return Column(
            children: [
              // --- Reusable Top Summary ---
              Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 138, 184, 179),
                // decoration: const BoxDecoration(
                //   color: Colors.amber, // same as AppBar
                //   // borderRadius: BorderRadius.only(
                //   //   // bottomLeft: Radius.circular(),
                //   //   // bottomRight: Radius.circular(16),
                //   // ),
                // ),
                // padding: const EdgeInsets.symmetric(
                //   vertical: 16,
                //   horizontal: 12,
                // ),
                child: TopSummary(
                  totalBudget: totalBudget,
                  totalSpent: totalSpent,
                ),
              ),

              const SizedBox(height: 8),

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
          );
        },
      ),
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
