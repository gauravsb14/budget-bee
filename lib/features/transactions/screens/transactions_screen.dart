import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/expense_model.dart';
import '../../shared/widgets/top_summary.dart';
// import '../../shared/widgets/top_bar.dart';

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
    _monthTabController.index =
        months.length - 1; // current month selected by default
    _monthTabController.addListener(() {
      setState(() {}); // rebuild when tab changes
    });
  }

  void _generateMonths() {
    final now = DateTime.now();
    months = List.generate(12, (i) {
      return DateTime(now.year, now.month - (11 - i), 1);
    });
  }

  @override
  void dispose() {
    _monthTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseBox = Hive.box<Expense>('expenses');
    final subBox = Hive.box<SubCategory>('subcategories');

    return ValueListenableBuilder(
      valueListenable: expenseBox.listenable(),
      builder: (context, Box<Expense> box, _) {
        final selectedMonthDate = months[_monthTabController.index];

        // --- Filtered expenses for selected month ---
        final expenses =
            box.values
                .where(
                  (e) =>
                      e.date.year == selectedMonthDate.year &&
                      e.date.month == selectedMonthDate.month,
                )
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        // --- Group by date ---
        final Map<String, List<Expense>> grouped = {};
        for (var e in expenses) {
          final dateKey = "${e.date.year}-${e.date.month}-${e.date.day}";
          grouped.putIfAbsent(dateKey, () => []);
          grouped[dateKey]!.add(e);
        }

        // --- Calculate Budget Summary ---
        final filteredSub = subBox.values.toList();
        double totalBudget = filteredSub.fold(
          0,
          (sum, s) => sum + s.monthlyBudget,
        );
        double totalExpense = expenses.fold(0, (sum, e) => sum + e.amount);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Transactions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 138, 184, 179),
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddExpenseDialog(context),
            backgroundColor: const Color.fromARGB(255, 138, 184, 179),
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              // --- Top Summary ---
              Container(
                color: const Color.fromARGB(255, 138, 184, 179),
                child: TopSummary(
                  totalBudget: totalBudget,
                  totalSpent: totalExpense,
                  month: selectedMonthDate.month,
                  year: selectedMonthDate.year,
                  textColor: Colors.white,
                ),
              ),
              // --- Month Tabs ---
              Container(
                height: 50,
                // color: const Color.fromARGB(255, 138, 184, 179),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TabBar(
                  controller: _monthTabController,
                  isScrollable: true,
                  indicatorColor: Color.fromARGB(255, 138, 184, 179),
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

              // --- Transaction List ---
              Expanded(
                child: expenses.isEmpty
                    ? const Center(
                        child: Text(
                          "No transactions for this month",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      )
                    : ListView(
                        children: grouped.entries.map((entry) {
                          final date = entry.key;
                          final dayExpenses = entry.value;

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
                                  date,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
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
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "₹${e.amount.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
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
                                                onPressed: () => _deleteExpense(
                                                  context,
                                                  e,
                                                  sub,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(color: Colors.grey[300], height: 1),
                                  ],
                                );
                              }),
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

  void _deleteExpense(
    BuildContext context,
    Expense expense,
    SubCategory? subcategory,
  ) {
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
              if (subcategory != null) {
                subcategory.spent -= expense.amount;
                if (subcategory.spent < 0) subcategory.spent = 0;
                subcategory.save();
              }
              expense.delete();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
