import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> data; // category -> amount

  const ExpensePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);

    final colors = [
      Colors.blueAccent.shade100,
      Colors.greenAccent.shade100,
      Colors.orangeAccent.shade100,
      Colors.purpleAccent.shade100,
      Colors.redAccent.shade100,
      Colors.tealAccent.shade100,
      Colors.yellowAccent.shade100,
      Colors.cyanAccent.shade100,
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pie chart with total in center
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sections: data.entries.map((entry) {
                        final index = data.keys.toList().indexOf(entry.key);
                        final value = entry.value;

                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: value,
                          radius: 30,
                          title: '',
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                    ),
                  ),
                  Center(
                    child: Text(
                      "₹${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Legends beside pie chart
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.entries.map((entry) {
                  final index = data.keys.toList().indexOf(entry.key);
                  final percentage = total == 0
                      ? "0%"
                      : "${((entry.value / total) * 100).toStringAsFixed(1)}%";

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors[index % colors.length],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${entry.key} ($percentage)",
                            style: const TextStyle(fontSize: 11),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
