import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/expense_model.dart';
import '../widgets/subcategory_tile.dart';
import '../widgets/expense_pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  bool isMonthly = true;
  TabController? _tabController;
  List<DateTime> months = [];
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _generateMonths();
    _tabController = TabController(length: months.length, vsync: this);
    _tabController!.index = months.length - 1; // default to current month
    _tabController!.addListener(() {
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
    _tabController?.dispose();
    super.dispose();
  }

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
          if (_tabController == null) return const CircularProgressIndicator();

          // --- Filter expenses ---
          List<Expense> filteredExpenses = [];
          if (isMonthly) {
            final selectedMonthDate = months[_tabController!.index];
            filteredExpenses = expensesBox.values
                .where(
                  (e) =>
                      e.date.year == selectedMonthDate.year &&
                      e.date.month == selectedMonthDate.month,
                )
                .toList();
          } else {
            filteredExpenses = expensesBox.values
                .where((e) => e.date.year == selectedYear)
                .toList();
          }

          // Map subcategory -> total spent
          final Map<int, double> subSpent = {};
          for (var e in filteredExpenses) {
            subSpent[e.subCategoryId] =
                (subSpent[e.subCategoryId] ?? 0) + e.amount;
          }

          final subcategories = subBox.values
              .where((s) => subSpent.containsKey(s.id))
              .toList();

          // Pie chart data
          final Map<String, double> pieData = {};
          for (var s in subcategories) {
            pieData[s.name] = subSpent[s.id]!;
          }

          return Column(
            children: [
              // --- Monthly / Yearly toggle ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Monthly"),
                      selected: isMonthly,
                      onSelected: (_) {
                        setState(() {
                          isMonthly = true;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Yearly"),
                      selected: !isMonthly,
                      onSelected: (_) {
                        setState(() {
                          isMonthly = false;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // --- Scrollable Monthly Tabs ---
              if (isMonthly)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: const Color.fromARGB(255, 138, 184, 179),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black87,
                    tabs: months
                        .map(
                          (m) => Tab(
                            child: Text(
                              "${monthName(m.month)} ${m.year}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onTap: (_) {
                      setState(() {}); // rebuild when tab selected
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // --- Pie Chart ---
              if (pieData.isNotEmpty) ExpensePieChart(data: pieData),

              const SizedBox(height: 16),

              // --- Subcategory Tiles ---
              Expanded(
                child: ListView.builder(
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final s = subcategories[index];
                    final spent = subSpent[s.id] ?? 0.0;

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
