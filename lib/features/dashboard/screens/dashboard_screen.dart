import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/expense_model.dart';
import '../widgets/subcategory_tile.dart';
import '../widgets/expense_pie_chart.dart'; // Updated pie chart with legends

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isMonthly = true; // Monthly/Yearly toggle
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final expenseBox = Hive.box<Expense>('expenses');
    final subBox = Hive.box<SubCategory>('subcategories');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color.fromARGB(255, 138, 184, 179),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, Box<Expense> expensesBox, _) {
          // Filter expenses based on month/year
          final expenses = expensesBox.values.where((e) {
            if (isMonthly) {
              return e.date.year == selectedYear &&
                  e.date.month == selectedMonth;
            } else {
              return e.date.year == selectedYear;
            }
          }).toList();

          // Map subcategory id -> total spent
          final Map<int, double> subSpent = {};
          for (var e in expenses) {
            subSpent[e.subCategoryId] =
                (subSpent[e.subCategoryId] ?? 0) + e.amount;
          }

          // Get subcategories with expenses
          final subcategories = subBox.values
              .where((s) => subSpent.containsKey(s.id))
              .toList();

          // Prepare pie chart data: subcategory name -> amount spent
          final Map<String, double> pieData = {};
          for (var s in subcategories) {
            pieData[s.name] = subSpent[s.id]!;
          }

          return Column(
            children: [
              // --- Monthly / Yearly Toggle ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Monthly"),
                      selected: isMonthly,
                      onSelected: (_) => setState(() => isMonthly = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Yearly"),
                      selected: !isMonthly,
                      onSelected: (_) => setState(() => isMonthly = false),
                    ),
                  ],
                ),
              ),

              // --- Horizontal Month Selector ---
              if (isMonthly)
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      return GestureDetector(
                        onTap: () => setState(() => selectedMonth = month),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selectedMonth == month
                                ? const Color.fromARGB(255, 138, 184, 179)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              monthName(month),
                              style: TextStyle(
                                color: selectedMonth == month
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // --- Pie Chart with total expense in center ---
              if (pieData.isNotEmpty) ExpensePieChart(data: pieData),

              const SizedBox(height: 16),

              // --- Subcategory Tiles with budget vs spent percentage ---
              Expanded(
                child: ListView.builder(
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final s = subcategories[index];
                    final spent = subSpent[s.id] ?? 0.0;

                    // Calculate % of budget spent
                    double percent = s.monthlyBudget == 0
                        ? 0
                        : (spent / s.monthlyBudget * 100);
                    String percentText = spent > s.monthlyBudget
                        ? "-${percent.toStringAsFixed(1)}%"
                        : "${percent.toStringAsFixed(1)}%";

                    return SubcategoryTile(
                      subcategory: s,
                      spent: spent,
                      percentBudgetSpent: percentText,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String monthName(int month) {
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
}
