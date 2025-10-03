import 'package:flutter/material.dart';

class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with dynamic data if needed
    final totalSpent = 12500.0;
    final savings = 8000.0;
    final income = 25000.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statCard('Income', income, Colors.green),
        _statCard('Spent', totalSpent, Colors.red),
        _statCard('Savings', savings, Colors.blue),
      ],
    );
  }

  Widget _statCard(String title, double amount, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: color)),
            const SizedBox(height: 4),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
