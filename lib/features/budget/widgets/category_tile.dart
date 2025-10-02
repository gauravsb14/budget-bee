import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/category_model.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/expense_model.dart';

class CategoryTile extends StatelessWidget {
  final Category category;

  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final subBox = Hive.box<SubCategory>('subcategories');
    final expenseBox = Hive.box<Expense>('expenses');

    return ValueListenableBuilder(
      valueListenable: subBox.listenable(),
      builder: (context, Box<SubCategory> box, _) {
        final subcategories = box.values
            .where((s) => s.parentCategoryId == category.id)
            .toList();

        double totalBudget = subcategories.fold(
          0,
          (sum, s) => sum + s.monthlyBudget,
        );
        double totalSpent = subcategories.fold(0, (sum, s) => sum + s.spent);
        double progress = totalBudget == 0 ? 0 : totalSpent / totalBudget;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress > 1 ? 1 : progress,
                  backgroundColor: Colors.grey[300],
                  color: progress > 1 ? Colors.red : Colors.green,
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${totalSpent.toStringAsFixed(2)} / ₹${totalBudget.toStringAsFixed(2)}",
                ),
              ],
            ),
            children: [
              for (var sub in subcategories)
                ListTile(
                  title: Text(sub.name),
                  subtitle: LinearProgressIndicator(
                    value: sub.monthlyBudget == 0
                        ? 0
                        : sub.spent / sub.monthlyBudget,
                    backgroundColor: Colors.grey[300],
                    color: sub.spent > sub.monthlyBudget
                        ? Colors.red
                        : Colors.green,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddExpenseDialog(context, sub),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showEditSubcategoryDialog(context, sub),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _deleteSubcategory(context, sub, expenseBox),
                      ),
                    ],
                  ),
                ),
              TextButton.icon(
                onPressed: () => _showAddSubcategoryDialog(context, category),
                icon: const Icon(Icons.add),
                label: const Text("Add Subcategory"),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Add Subcategory ---
  void _showAddSubcategoryDialog(BuildContext context, Category category) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    final subBox = Hive.box<SubCategory>('subcategories');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Subcategory - ${category.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Subcategory Name"),
            ),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(labelText: "Monthly Budget"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final budget = double.tryParse(budgetController.text) ?? 0;
              if (name.isEmpty) return;

              final sub = SubCategory(
                id: DateTime.now().millisecondsSinceEpoch,
                parentCategoryId: category.id,
                name: name,
                monthlyBudget: budget,
                spent: 0,
              );

              subBox.add(sub);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- Edit Subcategory ---
  void _showEditSubcategoryDialog(
    BuildContext context,
    SubCategory subcategory,
  ) {
    final nameController = TextEditingController(text: subcategory.name);
    final budgetController = TextEditingController(
      text: subcategory.monthlyBudget.toString(),
    );
    final subBox = Hive.box<SubCategory>('subcategories');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Subcategory"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Subcategory Name"),
            ),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(labelText: "Monthly Budget"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final budget = double.tryParse(budgetController.text) ?? 0;
              if (name.isEmpty) return;

              subcategory.name = name;
              subcategory.monthlyBudget = budget;
              subcategory.save();

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- Delete Subcategory ---
  void _deleteSubcategory(
    BuildContext context,
    SubCategory subcategory,
    Box<Expense> expenseBox,
  ) {
    // Delete all expenses under this subcategory
    final expenses = expenseBox.values
        .where((e) => e.subCategoryId == subcategory.id)
        .toList();
    for (var e in expenses) {
      e.delete();
    }

    subcategory.delete();
  }

  // --- Add Expense ---
  void _showAddExpenseDialog(BuildContext context, SubCategory subcategory) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final expenseBox = Hive.box<Expense>('expenses');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Expense - ${subcategory.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Note"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) return;

              final expense = Expense(
                id: DateTime.now().millisecondsSinceEpoch,
                subCategoryId: subcategory.id,
                amount: amount,
                note: noteController.text,
                date: DateTime.now(),
              );

              expenseBox.add(expense);
              subcategory.spent += amount;
              subcategory.save();

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
