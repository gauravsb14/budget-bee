import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final double remaining;

  const SummaryCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text("Total Budget"),
                Text("₹${totalBudget.toStringAsFixed(2)}"),
              ],
            ),
            Column(
              children: [
                const Text("Spent"),
                Text("₹${totalSpent.toStringAsFixed(2)}"),
              ],
            ),
            Column(
              children: [
                const Text("Remaining"),
                Text("₹${remaining.toStringAsFixed(2)}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
