import 'package:flutter/material.dart';
import '../../../models/subcategory_model.dart';

class SubcategoryTile extends StatelessWidget {
  final SubCategory subcategory;
  final double spent;
  final String percentBudgetSpent; // e.g., "75%" or "-120%"

  const SubcategoryTile({
    super.key,
    required this.subcategory,
    required this.spent,
    required this.percentBudgetSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Subcategory name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subcategory.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${spent.toStringAsFixed(2)} / ₹${subcategory.monthlyBudget.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),

            // % of budget spent
            Text(
              percentBudgetSpent,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: percentBudgetSpent.startsWith('-')
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
