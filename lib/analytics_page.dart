import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/expense_provider.dart';
import 'models/expense_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final Color accentPurple = const Color(0xFF8A5BFF);
  final Color accentBlue = const Color(0xFF00A9FF);
  final Color accentGreen = const Color(0xFF00C48C);
  final Color accentOrange = const Color(0xFFFF9800);
  final Color lightBg = const Color(0xFFF9F9F9);

  // Category colors mapping
  final Map<String, int> categoryColors = {
    "Food & Dining": 0xFFE74C3C,
    "Transportation": 0xFF00A9FF,
    "Bills & Utilities": 0xFF00C48C,
    "Shopping": 0xFFFF9800,
    "Healthcare": 0xFFE91E63,
    "Entertainment": 0xFF673AB7,
  };

  BoxDecoration commonCardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final currentMonthExpenses = expenseProvider.getCurrentMonthExpenses();
        final lastMonthExpenses = _getLastMonthExpenses(expenseProvider.expenses);
        final last7DaysData = _getLast7DaysData(expenseProvider.expenses);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: lightBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(
                        "This Month",
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _insightsCard(currentMonthExpenses, lastMonthExpenses),
                const SizedBox(height: 12),
                _weeklyTrendCard(last7DaysData),
                const SizedBox(height: 12),
                _categoryBreakdownCard(currentMonthExpenses, lastMonthExpenses),
                const SizedBox(height: 12),
                _topCategoriesRow(currentMonthExpenses),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Expense> _getLastMonthExpenses(List<Expense> allExpenses) {
    final now = DateTime.now();
    final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayLastMonth = DateTime(now.year, now.month, 0);

    return allExpenses.where((expense) {
      return expense.date.isAfter(firstDayLastMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(lastDayLastMonth.add(const Duration(days: 1)));
    }).toList();
  }

  List<double> _getLast7DaysData(List<Expense> allExpenses) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DateTime(date.year, date.month, date.day);
    });

    return last7Days.map((day) {
      final dayExpenses = allExpenses.where((expense) {
        final expenseDay = DateTime(expense.date.year, expense.date.month, expense.date.day);
        return expenseDay == day;
      }).toList();

      return dayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    }).toList();
  }

  Widget _insightsCard(List<Expense> currentMonth, List<Expense> lastMonth) {
    final currentTotal = currentMonth.fold(0.0, (sum, e) => sum + e.amount);
    final lastTotal = lastMonth.fold(0.0, (sum, e) => sum + e.amount);
    final change = lastTotal > 0 ? ((currentTotal - lastTotal) / lastTotal * 100) : 0.0;
    final isIncrease = change > 0;

    // Get top spending category
    final Map<String, double> categoryTotals = {};
    for (final expense in currentMonth) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    final topCategory = categoryTotals.entries.isEmpty
        ? null
        : categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.lightbulb_fill, color: accentOrange),
              const SizedBox(width: 8),
              const Text(
                "Insights",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (currentMonth.isEmpty)
            _insight(
              "Start Tracking",
              "No expenses recorded yet. Start adding your expenses to get insights!",
              const Color(0xFFE8F5FE),
              accentBlue,
            )
          else ...[
            _insight(
              isIncrease ? "Spending Increased" : "Great Progress!",
              isIncrease
                  ? "You spent ${change.abs().toStringAsFixed(1)}% more than last month. Consider reviewing your budget."
                  : "You spent ${change.abs().toStringAsFixed(1)}% less than last month. Keep it up!",
              isIncrease ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
              isIncrease ? accentOrange : accentGreen,
            ),
            if (topCategory != null) ...[
              const SizedBox(height: 10),
              _insight(
                "Top Category",
                "${topCategory.key} is your highest expense at ৳${topCategory.value.toStringAsFixed(0)}. Consider ways to optimize this category.",
                const Color(0xFFF3E8FF),
                accentPurple,
              ),
            ],
            const SizedBox(height: 10),
            _insight(
              "Monthly Summary",
              "You've recorded ${currentMonth.length} transactions this month totaling ৳${currentTotal.toStringAsFixed(2)}.",
              const Color(0xFFE8F5FE),
              accentBlue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _insight(String title, String subtitle, Color bg, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bg.withOpacity(0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(CupertinoIcons.info, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyTrendCard(List<double> weekData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Last 7 Days Spending",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: weekData.every((element) => element == 0)
                ? Center(
                    child: Text(
                      "No data for the last 7 days",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : CustomPaint(
                    painter: LineChartPainter(weekData, accentPurple),
                    child: Container(),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.chart_bar,
                      color: Color(0xFF2E7D32),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Avg: ৳${(weekData.reduce((a, b) => a + b) / 7).toStringAsFixed(0)}/day",
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  DateFormat('MMM dd').format(DateTime.now()),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryBreakdownCard(List<Expense> currentMonth, List<Expense> lastMonth) {
    // Calculate category totals for current and last month
    final Map<String, double> currentCategoryTotals = {};
    final Map<String, double> lastCategoryTotals = {};

    for (final expense in currentMonth) {
      currentCategoryTotals[expense.category] =
          (currentCategoryTotals[expense.category] ?? 0) + expense.amount;
    }

    for (final expense in lastMonth) {
      lastCategoryTotals[expense.category] =
          (lastCategoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Combine all categories
    final allCategories = {...currentCategoryTotals.keys, ...lastCategoryTotals.keys}.toList();
    final categories = allCategories.map((cat) {
      return {
        "name": cat,
        "color": categoryColors[cat] ?? 0xFF9E9E9E,
        "thisMonth": currentCategoryTotals[cat] ?? 0.0,
        "lastMonth": lastCategoryTotals[cat] ?? 0.0,
      };
    }).toList()
      ..sort((a, b) =>
          (b["thisMonth"] as double).compareTo(a["thisMonth"] as double));

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: commonCardDecoration(),
        child: Column(
          children: const [
            Icon(CupertinoIcons.chart_bar, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              "No category data available",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Category Breakdown",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...categories.take(6).map((c) => _categoryRow(c)),
        ],
      ),
    );
  }

  Widget _categoryRow(Map<String, dynamic> c) {
    final double thisMonth = c["thisMonth"] as double;
    final double lastMonth = c["lastMonth"] as double;
    final double maxValue = thisMonth > lastMonth ? thisMonth : lastMonth;
    final double thisRatio = maxValue > 0 ? thisMonth / maxValue : 0;
    final double lastRatio = maxValue > 0 ? lastMonth / maxValue : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c["name"] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                "৳${thisMonth.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: thisRatio.clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(c["color"] as int),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "This Month",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: FractionallySizedBox(
                  widthFactor: lastRatio.clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "৳${lastMonth.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topCategoriesRow(List<Expense> currentMonth) {
    if (currentMonth.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate category totals
    final Map<String, double> categoryTotals = {};
    for (final expense in currentMonth) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highestCategory = sortedCategories.first;
    final lowestCategory = sortedCategories.length > 1
        ? sortedCategories.last
        : sortedCategories.first;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: commonCardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_up,
                    color: Color(0xFFD32F2F),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Highest",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        highestCategory.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "৳${highestCategory.value.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: commonCardDecoration(),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_down,
                    color: Color(0xFF2E7D32),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Lowest",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lowestCategory.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "৳${lowestCategory.value.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  LineChartPainter(this.values, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axisPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height - 24),
      Offset(size.width, size.height - 24),
      axisPaint,
    );

    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double minVal = values.reduce((a, b) => a < b ? a : b);
    final double chartHeight = size.height - 40;
    final double dx = size.width / (values.length - 1);

    final Path path = Path();
    for (int i = 0; i < values.length; i++) {
      final double norm =
          maxVal > minVal ? (values[i] - minVal) / (maxVal - minVal) : 0.5;
      final double y = (1 - norm) * chartHeight + 8;
      final double x = i * dx;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, linePaint);

    final Paint dotPaint = Paint()..color = lineColor;
    for (int i = 0; i < values.length; i++) {
      final double norm =
          maxVal > minVal ? (values[i] - minVal) / (maxVal - minVal) : 0.5;
      final double y = (1 - norm) * chartHeight + 8;
      final double x = i * dx;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
