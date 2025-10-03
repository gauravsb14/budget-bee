import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;

  const TopBar({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 138, 184, 179),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // --- Year Dropdown ---
          DropdownButton<int>(
            value: selectedYear,
            dropdownColor: Colors.white,
            style: const TextStyle(
              // 👈 style for selected value
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            iconEnabledColor: Color.fromARGB(
              255,
              35,
              48,
              124,
            ), // 👈 dropdown arrow color
            items: List.generate(5, (i) => DateTime.now().year - i)
                .map(
                  (y) => DropdownMenuItem(
                    value: y,
                    child: Text(
                      "$y",
                      style: const TextStyle(
                        color: Color.fromARGB(
                          255,
                          35,
                          48,
                          124,
                        ), // 👈 color inside dropdown list
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) onYearChanged(val);
            },
          ),
          const SizedBox(width: 8),

          // --- Month Dropdown ---
          DropdownButton<int>(
            value: selectedMonth,
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Color.fromARGB(255, 35, 48, 124),
              fontWeight: FontWeight.bold,
            ),
            iconEnabledColor: Color.fromARGB(255, 35, 48, 124),
            items: List.generate(12, (i) => i + 1)
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(
                      [
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
                      ][m - 1],
                      style: const TextStyle(
                        color: Color.fromARGB(
                          255,
                          35,
                          48,
                          124,
                        ), // 👈 dropdown menu items
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) onMonthChanged(val);
            },
          ),
        ],
      ),
    );
  }
}
