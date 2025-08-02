import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SimpleCalendarRow extends StatelessWidget {
  final DateTime selectedDate;

  const SimpleCalendarRow({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 3));
    final endDate = now.add(const Duration(days: 10));

    final days = List.generate(
      endDate.difference(startDate).inDays + 1,
      (i) => startDate.add(Duration(days: i)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 8),
        SizedBox(
          height: 74, // ⬅️ Ukuran lebih ringkas dari sebelumnya
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected =
                  date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;

              return IgnorePointer(
                child: Container(
                  width: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.green
                        : isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(2, 6),
                        blurRadius: 10,
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : theme.primaryColor,
                        ),
                      ),
                      Text(
                        DateFormat('EEE', 'id_ID').format(date),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white70
                              : theme.textTheme.bodySmall?.color?.withAlpha(
                                  178,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
