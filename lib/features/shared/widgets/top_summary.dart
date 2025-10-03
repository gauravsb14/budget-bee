import 'package:flutter/material.dart';

class TopSummary extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final int month; // 1-12
  final int year;
  final Color textColor; // For text labels & amounts

  const TopSummary({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.month,
    required this.year,
    this.textColor = const Color.fromARGB(221, 46, 46, 46),
  });

  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final remaining = totalBudget - totalSpent;

    return Container(
      width: double.infinity,
      color: const Color.fromARGB(255, 138, 184, 179),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ), // tiny vertical
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSummaryColumn("Total Budget", totalBudget, textColor),
          _buildSummaryColumn("Spent", totalSpent, textColor),
          _buildSummaryColumn("Remaining", remaining, textColor),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String title, double amount, Color textColor) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount > 0 ? "₹${amount.toStringAsFixed(2)}" : "-",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
