import 'package:flutter/material.dart';

class TopSummary extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final Color textColor; // new (for labels + amounts)

  const TopSummary({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    this.textColor = const Color.fromARGB(221, 46, 46, 46), // default
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalBudget - totalSpent;

    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      // decoration: BoxDecoration(
      //   color: Colors.amber, // background for summary section
      //   // borderRadius: BorderRadius.horizontal(1),
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      // mainAxisSize: MainAxisSize.min,
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
          "₹${amount.toStringAsFixed(2)}",
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
