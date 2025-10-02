import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/expense_model.dart';
import '../../shared/widgets/top_summary.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseBox = Hive.box<Expense>('expenses');
    final subBox = Hive.box<SubCategory>('subcategories');

    return ValueListenableBuilder(
      valueListenable: expenseBox.listenable(),
      builder: (context, Box<Expense> box, _) {
        final expenses = box.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        // --- Group by date ---
        final Map<String, List<Expense>> grouped = {};
        for (var e in expenses) {
          final dateKey = "${e.date.year}-${e.date.month}-${e.date.day}";
          grouped.putIfAbsent(dateKey, () => []);
          grouped[dateKey]!.add(e);
        }

        // --- Calculate Top Summary ---
        double totalBudget = subBox.values.fold(
          0,
          (sum, s) => sum + s.monthlyBudget,
        );
        double totalExpense = expenses.fold(0, (sum, e) => sum + e.amount);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Budget Bee"),
            backgroundColor: const Color.fromARGB(255, 138, 184, 179),
            foregroundColor: Colors.white,
            elevation: 1,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddExpenseDialog(context),
            backgroundColor: const Color.fromARGB(255, 138, 184, 179),
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              // --- Top Summary (same style as BudgetScreen) ---
              Container(
                width: double.infinity,
                color: const Color.fromARGB(
                  255,
                  138,
                  184,
                  179,
                ), // same as AppBar for consistency
                child: TopSummary(
                  totalBudget: totalBudget,
                  totalSpent: totalExpense,
                ),
              ),

              const SizedBox(height: 8),

              // --- Expense List Grouped by Date ---
              Expanded(
                child: ListView(
                  children: grouped.entries.map((entry) {
                    final date = entry.key;
                    final dayExpenses = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Date Header ---
                        Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // --- Transactions ---
                        ...dayExpenses.map((e) {
                          final sub = subBox.values.firstWhere(
                            (s) => s.id == e.subCategoryId,
                            orElse: () => SubCategory(
                              id: 0,
                              parentCategoryId: 0,
                              name: "Unknown",
                              monthlyBudget: 0,
                              spent: 0,
                            ),
                          );

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left: subcategory + note
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sub.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                              221,
                                              46,
                                              46,
                                              46,
                                            ),
                                          ),
                                        ),
                                        if (e.note.isNotEmpty)
                                          Text(
                                            e.note,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Right: Amount
                                    Text(
                                      "₹${e.amount.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: e.amount > 0
                                            ? Colors.red[400] // expense
                                            : Colors.green[600], // credit
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.grey[300], height: 1),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    int? selectedSubId;
    final subBox = Hive.box<SubCategory>('subcategories');
    final expenseBox = Hive.box<Expense>('expenses');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Subcategory"),
              items: subBox.values
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: (val) => selectedSubId = val,
            ),
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
              if (selectedSubId == null || amountController.text.isEmpty)
                return;
              final expense = Expense(
                id: DateTime.now().millisecondsSinceEpoch,
                subCategoryId: selectedSubId!,
                amount: double.tryParse(amountController.text) ?? 0,
                note: noteController.text,
                date: DateTime.now(),
              );
              expenseBox.add(expense);

              // Update spent for subcategory
              final sub = subBox.values.firstWhere(
                (s) => s.id == selectedSubId,
              );
              sub.spent += expense.amount;
              sub.save();

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
