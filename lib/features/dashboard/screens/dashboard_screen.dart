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

  // Controllers
  TabController? _monthTabController;
  TabController? _yearTabController;

  List<DateTime> months = [];
  List<int> years = [];
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _generateMonths();
    _generateYears();

    _monthTabController = TabController(length: months.length, vsync: this);
    _monthTabController!.index = months.length - 1;
    _monthTabController!.addListener(() => setState(() {}));

    _yearTabController = TabController(length: years.length, vsync: this);
    _yearTabController!.index = years.length - 1;
    _yearTabController!.addListener(() {
      setState(() {
        selectedYear = years[_yearTabController!.index];
      });
    });
  }

  void _generateMonths() {
    final now = DateTime.now();
    months = List.generate(
      12,
      (i) => DateTime(now.year, now.month - (11 - i), 1),
    );
  }

  void _generateYears() {
    final currentYear = DateTime.now().year;
    years = List.generate(5, (i) => currentYear - (4 - i));
  }

  @override
  void dispose() {
    _monthTabController?.dispose();
    _yearTabController?.dispose();
    super.dispose();
  }

  String getMonthKey(DateTime date) => "${date.year}-${date.month}";

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
          // --- Filter expenses ---
          List<Expense> filteredExpenses = [];
          String? monthKey;

          if (isMonthly) {
            if (_monthTabController == null) return const SizedBox();
            final selectedMonthDate = months[_monthTabController!.index];
            monthKey = getMonthKey(selectedMonthDate);
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

          // Filter subcategories that have expenses
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

              // --- Month Tabs ---
              if (isMonthly)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TabBar(
                    controller: _monthTabController,
                    isScrollable: true,
                    indicatorColor: const Color.fromARGB(255, 138, 184, 179),
                    labelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    unselectedLabelColor: Colors.black87,
                    tabs: months
                        .map(
                          (m) => Tab(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "${monthName(m.month)} ${m.year}",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

              // --- Year Tabs ---
              if (!isMonthly)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TabBar(
                    controller: _yearTabController,
                    isScrollable: false,
                    indicatorColor: const Color.fromARGB(255, 138, 184, 179),
                    labelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    unselectedLabelColor: Colors.black87,
                    tabs: years
                        .map(
                          (y) => Tab(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                y.toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        )
                        .toList(),
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

                    // Use monthlyBudgets map for monthly view
                    final budget = isMonthly && monthKey != null
                        ? s.monthlyBudgets[monthKey] ?? 0
                        : s.monthlyBudgets.values.fold(0.0, (a, b) => a + b);

                    double percent = budget == 0 ? 0 : (spent / budget * 100);
                    String percentText = spent > budget
                        ? "-${percent.toStringAsFixed(1)}%"
                        : "${percent.toStringAsFixed(1)}%";

                    return SubcategoryTile(
                      subcategory: s,
                      spent: spent,
                      percentBudgetSpent: percentText,
                      monthlyBudget: budget,
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
