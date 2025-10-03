import 'package:flutter/material.dart';
import '../../shared/widgets/top_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 35, 48, 124),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 138, 184, 179),
        elevation: 0, // ✅ makes it flush with TopBar
      ),
      body: Column(
        children: [
          // ✅ TopBar with same background color
          Container(
            color: const Color.fromARGB(255, 138, 184, 179),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: TopBar(
              selectedYear: selectedYear,
              selectedMonth: selectedMonth,
              onYearChanged: (year) {
                setState(() => selectedYear = year);
              },
              onMonthChanged: (month) {
                setState(() => selectedMonth = month);
              },
            ),
          ),

          // Dashboard content
          Expanded(
            child: Center(
              child: Text(
                "Dashboard content for $selectedMonth/$selectedYear",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
