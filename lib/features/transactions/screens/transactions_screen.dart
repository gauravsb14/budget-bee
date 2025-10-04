import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/expense_model.dart';
import '../../shared/widgets/top_summary.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
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

  String _monthKey(DateTime date) => "${date.year}-${date.month}";
  String _dayKey(DateTime date) => "${date.year}-${date.month}-${date.day}";

  String _monthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final expenseBox = Hive.box<Expense>('expenses');
    final subBox = Hive.box<SubCategory>('subcategories');
    final selectedMonth = months[_monthTabController.index];
    final monthKey = _monthKey(selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transactions",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 138, 184, 179),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, selectedMonth),
        backgroundColor: const Color.fromARGB(255, 138, 184, 179),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // --- Listen to expenses and subcategories ---
          Expanded(
            child: ValueListenableBuilder<Box<Expense>>(
              valueListenable: expenseBox.listenable(),
              builder: (context, expenseBoxValue, _) {
                final monthlyExpenses =
                    expenseBoxValue.values
                        .where(
                          (e) =>
                              e.date.year == selectedMonth.year &&
                              e.date.month == selectedMonth.month,
                        )
                        .toList()
                      ..sort((a, b) => b.date.compareTo(a.date));

                // Group expenses by day
                final Map<String, List<Expense>> groupedExpenses = {};
                for (var e in monthlyExpenses) {
                  final dayKey = _dayKey(e.date);
                  groupedExpenses.putIfAbsent(dayKey, () => []);
                  groupedExpenses[dayKey]!.add(e);
                }

                // Calculate totals dynamically
                double totalBudget = subBox.values.fold(0.0, (sum, sub) {
                  return sum + (sub.monthlyBudgets[monthKey] ?? 0);
                });
                double totalSpent = monthlyExpenses.fold(
                  0.0,
                  (sum, e) => sum + e.amount,
                );

                return Column(
                  children: [
                    // --- Top Summary BEFORE Month Tabs ---
                    Container(
                      color: const Color.fromARGB(255, 138, 184, 179),
                      child: TopSummary(
                        totalBudget: totalBudget,
                        totalSpent: totalSpent,
                        month: selectedMonth.month,
                        year: selectedMonth.year,
                        textColor: Colors.white,
                      ),
                    ),

                    // --- Month Tabs ---
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

                    // --- Expense List ---
                    Expanded(
                      child: monthlyExpenses.isEmpty
                          ? const Center(
                              child: Text(
                                "No transactions for this month",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView(
                              children: groupedExpenses.entries.map((entry) {
                                final day = entry.key;
                                final expenses = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        day,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    ...expenses.map((e) {
                                      final sub = subBox.values.firstWhere(
                                        (s) => s.id == e.subCategoryId,
                                        orElse: () => SubCategory(
                                          id: 0,
                                          parentCategoryId: 0,
                                          name: "Unknown",
                                          monthlyBudgets: {},
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      sub.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "₹${e.amount.toStringAsFixed(2)}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 12,
                                                        color: e.amount > 0
                                                            ? Colors.red[400]
                                                            : Colors.green[600],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                      onPressed: () =>
                                                          _deleteExpense(
                                                            context,
                                                            e,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.grey[300],
                                            height: 1,
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Add Expense ---
  void _showAddExpenseDialog(BuildContext context, DateTime selectedMonth) {
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
              expenseBox.add(expense); // UI updates automatically

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- Delete Expense ---
  void _deleteExpense(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              expense.delete(); // UI updates automatically
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
