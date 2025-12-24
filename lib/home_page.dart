import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/expense_provider.dart';
import 'providers/auth_provider.dart';
import 'models/expense_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color accentPurple = const Color(0xFF8A5BFF);
  final Color accentBlue = const Color(0xFF00A9FF);
  final Color accentGreen = const Color(0xFF00C48C);
  final Color accentOrange = const Color(0xFFFF9800);
  final Color lightBg = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    // Load expenses when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).loadRecentExpenses();
    });
  }

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

  // Category colors mapping
  final Map<String, int> categoryColors = {
    "Food & Dining": 0xFFE74C3C,
    "Transportation": 0xFF00A9FF,
    "Bills & Utilities": 0xFF00C48C,
    "Shopping": 0xFFFF9800,
    "Healthcare": 0xFFE91E63,
    "Entertainment": 0xFF673AB7,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading && expenseProvider.expenses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = expenseProvider.expenses;
        final currentMonthExpenses = expenseProvider.getCurrentMonthExpenses();
        final todayExpenses = expenseProvider.getTodayExpenses();

        return RefreshIndicator(
          onRefresh: () => expenseProvider.refreshExpenses(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _greetingHeader(),
                  const SizedBox(height: 12),
                  _summaryCard(currentMonthExpenses),
                  const SizedBox(height: 12),
                  _spendingByCategoryCard(currentMonthExpenses),
                  const SizedBox(height: 12),
                  _recentTransactionsCard(expenses.take(5).toList()),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statTile(
                          icon: CupertinoIcons.money_dollar,
                          label: "Today's Spending",
                          value:
                              "৳${_calculateTotal(todayExpenses).toStringAsFixed(2)}",
                          bg: const Color(0xFFE8F5E9),
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statTile(
                          icon: CupertinoIcons.doc_text,
                          label: "Total Expenses",
                          value: "${expenses.length}",
                          bg: const Color(0xFFE8F5FE),
                          color: const Color(0xFF0277BD),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Widget _greetingHeader() {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.currentUser?.name ?? 'User';

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$greeting, $userName! 👋",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Track your expenses wisely",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard(List<Expense> monthExpenses) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final total = _calculateTotal(monthExpenses);
        final budget = authProvider.currentUser?.monthlyBudget ?? 50000.0;
        final remaining = budget - total;
        final percentage = total / budget;
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final daysLeft = daysInMonth - now.day;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [accentPurple, const Color.fromARGB(255, 48, 22, 167)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Spent This Month",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "৳${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      CupertinoIcons.chart_bar,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Budget: ৳${budget.toStringAsFixed(0)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(
                    "Remaining: ৳${remaining.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage.clamp(0.0, 1.0),
                  minHeight: 8,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${(percentage * 100).toStringAsFixed(1)}% used",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$daysLeft days left",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _spendingByCategoryCard(List<Expense> monthExpenses) {
    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    double total = 0;

    for (final expense in monthExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
      total += expense.amount;
    }

    // Convert to list and sort
    final categories =
        categoryTotals.entries
            .map(
              (e) => {
                "name": e.key,
                "amount": e.value,
                "color": categoryColors[e.key] ?? 0xFF9E9E9E,
                "percent": total > 0 ? ((e.value / total) * 100).round() : 0,
              },
            )
            .toList()
          ..sort(
            (a, b) => (b["amount"] as double).compareTo(a["amount"] as double),
          );

    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: commonCardDecoration(),
        child: Column(
          children: [
            Icon(CupertinoIcons.chart_pie, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              "No expenses yet this month",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Spending by Category",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                ),
                child: Text(monthName),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    categories.map((e) => e["amount"] as double).toList(),
                    categories.map((e) => Color(e["color"] as int)).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: categories.take(5).map((c) => _catRow(c)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _catRow(Map<String, dynamic> c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Color(c["color"] as int),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              c["name"] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "৳${(c["amount"] as double).toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Text(
            "${c["percent"]}%",
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentTransactionsCard(List<Expense> recentExpenses) {
    if (recentExpenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: commonCardDecoration(),
        child: Column(
          children: [
            Icon(CupertinoIcons.doc_text, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              "No transactions yet",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                "Recent Transactions",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Spacer(),
              Text(
                "Latest",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...recentExpenses.map((expense) => _txnItem(expense)),
        ],
      ),
    );
  }

  Widget _txnItem(Expense expense) {
    final isToday = _isToday(expense.date);
    final isYesterday = _isYesterday(expense.date);
    String dateLabel;
    if (isToday) {
      dateLabel = "Today";
    } else if (isYesterday) {
      dateLabel = "Yesterday";
    } else {
      dateLabel = DateFormat('MMM dd').format(expense.date);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: commonCardDecoration(),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: accentPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      Text(
                        expense.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        "•",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.3),
                        ),
                      ),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              "৳${expense.amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Food & Dining":
        return CupertinoIcons.cart;
      case "Transportation":
        return CupertinoIcons.car;
      case "Bills & Utilities":
        return CupertinoIcons.bolt;
      case "Shopping":
        return CupertinoIcons.bag;
      case "Healthcare":
        return CupertinoIcons.heart;
      case "Entertainment":
        return CupertinoIcons.game_controller;
      default:
        return CupertinoIcons.circle;
    }
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required Color bg,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  DonutChartPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final double total = values.fold(0, (p, c) => p + c);
    if (total == 0) return;

    final double thickness = 20;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    final Paint bg = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawCircle(center, radius - thickness / 2, bg);

    double start = -90 * 3.1415926535 / 180;
    for (int i = 0; i < values.length; i++) {
      final double sweep = (values[i] / total) * 2 * 3.1415926535;
      final Paint p = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = thickness;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - thickness / 2),
        start,
        sweep,
        false,
        p,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
