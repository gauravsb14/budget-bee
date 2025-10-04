import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/category_model.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/expense_model.dart';
import '../widgets/category_tile.dart';
import '../../shared/widgets/top_summary.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with TickerProviderStateMixin {
  late TabController _monthTabController;
  List<DateTime> months = [];

  @override
  void initState() {
    super.initState();
    _generateMonths();

    _monthTabController = TabController(length: months.length, vsync: this);
    _monthTabController.index = months.length - 1; // current month selected
    _monthTabController.addListener(() => setState(() {}));
  }

  void _generateMonths() {
    final now = DateTime.now();
    months = List.generate(
      12,
      (i) => DateTime(now.year, now.month - (11 - i), 1),
    );
  }

  @override
  void dispose() {
    _monthTabController.dispose();
    super.dispose();
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final categoryBox = Hive.box<Category>('categories');
    final subBox = Hive.box<SubCategory>('subcategories');
    final expenseBox = Hive.box<Expense>('expenses');

    final selectedMonthDate = months[_monthTabController.index];
    final monthKey = "${selectedMonthDate.year}-${selectedMonthDate.month}";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Budget",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 138, 184, 179),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: const Color.fromARGB(255, 138, 184, 179),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: categoryBox.listenable(),
        builder: (context, Box<Category> categories, _) {
          return ValueListenableBuilder(
            valueListenable: subBox.listenable(),
            builder: (context, Box<SubCategory> subs, _) {
              return ValueListenableBuilder(
                valueListenable: expenseBox.listenable(),
                builder: (context, Box<Expense> expenses, _) {
                  // --- Calculate top summary ---
                  double totalBudget = 0;
                  double totalSpent = 0;

                  for (var cat in categories.values) {
                    final catSubs = subs.values
                        .where((s) => s.parentCategoryId == cat.id)
                        .toList();
                    for (var sub in catSubs) {
                      totalBudget += sub.monthlyBudgets[monthKey] ?? 0;

                      final subExpenses = expenses.values
                          .where(
                            (e) =>
                                e.subCategoryId == sub.id &&
                                e.date.year == selectedMonthDate.year &&
                                e.date.month == selectedMonthDate.month,
                          )
                          .toList();
                      totalSpent += subExpenses.fold(
                        0.0,
                        (sum, e) => sum + e.amount,
                      );
                    }
                  }

                  // --- Build UI ---
                  return Column(
                    children: [
                      // Top Summary
                      Container(
                        color: const Color.fromARGB(255, 138, 184, 179),
                        child: TopSummary(
                          totalBudget: totalBudget,
                          totalSpent: totalSpent,
                          month: selectedMonthDate.month,
                          year: selectedMonthDate.year,
                          textColor: Colors.white,
                        ),
                      ),

                      // Month Tabs
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TabBar(
                          controller: _monthTabController,
                          isScrollable: true,
                          indicatorColor: const Color.fromARGB(
                            255,
                            138,
                            184,
                            179,
                          ),
                          labelColor: Colors.black87,
                          unselectedLabelColor: Colors.black87,
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: months
                              .map(
                                (m) => Tab(
                                  child: Text(
                                    "${_monthName(m.month)} ${m.year}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                      // Category Tiles
                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) => CategoryTile(
                            category: categories.values.elementAt(index),
                            selectedMonthDate: selectedMonthDate,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

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
