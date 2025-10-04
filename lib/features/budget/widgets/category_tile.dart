import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/category_model.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/expense_model.dart';

class CategoryTile extends StatefulWidget {
  final Category category;
  final DateTime selectedMonthDate;

  const CategoryTile({
    super.key,
    required this.category,
    required this.selectedMonthDate,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _expanded = false;

  String get monthKey =>
      "${widget.selectedMonthDate.year}-${widget.selectedMonthDate.month}";

  @override
  Widget build(BuildContext context) {
    final subBox = Hive.box<SubCategory>('subcategories');
    final expenseBox = Hive.box<Expense>('expenses');

    return ValueListenableBuilder(
      valueListenable: subBox.listenable(),
      builder: (context, Box<SubCategory> box, _) {
        final subcategories = box.values
            .where((s) => s.parentCategoryId == widget.category.id)
            .toList();

        // --- Calculate total for this category based on selected month ---
        double totalBudget = 0;
        double totalSpent = 0;

        for (var sub in subcategories) {
          double subBudget = sub.monthlyBudgets[monthKey] ?? 0;

          final subExpenses = expenseBox.values.where(
            (e) =>
                e.subCategoryId == sub.id &&
                e.date.year == widget.selectedMonthDate.year &&
                e.date.month == widget.selectedMonthDate.month,
          );
          final subSpent = subExpenses.fold(0.0, (sum, e) => sum + e.amount);

          totalBudget += subBudget;
          totalSpent += subSpent;
        }

        double progress = totalBudget == 0 ? 0 : totalSpent / totalBudget;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: Column(
            children: [
              // --- Category Header ---
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.category.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: progress > 1 ? 1 : progress,
                          backgroundColor: Colors.grey[300],
                          color: progress > 1 ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${totalSpent.toStringAsFixed(2)} / ₹${totalBudget.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Subcategories ---
              if (_expanded)
                Column(
                  children: [
                    const Divider(height: 1),
                    for (var sub in subcategories)
                      Builder(
                        builder: (context) {
                          double subBudget = sub.monthlyBudgets[monthKey] ?? 0;

                          final subExpenses = expenseBox.values.where(
                            (e) =>
                                e.subCategoryId == sub.id &&
                                e.date.year == widget.selectedMonthDate.year &&
                                e.date.month == widget.selectedMonthDate.month,
                          );
                          final subSpent = subExpenses.fold(
                            0.0,
                            (sum, e) => sum + e.amount,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sub.name,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        height: 6,
                                        child: LinearProgressIndicator(
                                          value: subBudget == 0
                                              ? 0
                                              : subSpent / subBudget,
                                          backgroundColor: Colors.grey[300],
                                          color: subSpent > subBudget
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "₹${subSpent.toStringAsFixed(2)} / ₹${subBudget.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_note,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _showEditSubcategoryDialog(
                                            context,
                                            sub,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => _deleteSubcategory(
                                        context,
                                        sub,
                                        expenseBox,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    // Add Subcategory Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextButton.icon(
                        onPressed: () =>
                            _showAddSubcategoryDialog(context, widget.category),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          "Add Subcategory",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // --- Edit Subcategory (month-specific budget) ---
  void _showEditSubcategoryDialog(BuildContext context, SubCategory sub) {
    final nameController = TextEditingController(text: sub.name);
    final budgetController = TextEditingController(
      text: (sub.monthlyBudgets[monthKey] ?? 0).toString(),
    );
    final subBox = Hive.box<SubCategory>('subcategories');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Subcategory", style: TextStyle(fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Sub Category Name"),
              style: const TextStyle(fontSize: 13),
            ),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(labelText: "Monthly Budget"),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
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

              sub.name = name;
              sub.monthlyBudgets[monthKey] = budget; // ✅ Month-specific update
              sub.save();
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
    SubCategory sub,
    Box<Expense> expenseBox,
  ) {
    final expenses = expenseBox.values
        .where((e) => e.subCategoryId == sub.id)
        .toList();
    for (var e in expenses) e.delete();
    sub.delete();
  }

  // --- Add Subcategory (new month-aware) ---
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
              style: const TextStyle(fontSize: 13),
            ),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(labelText: "Monthly Budget"),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
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
                monthlyBudgets: {monthKey: budget}, // ✅ Month-specific budget
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
}
