import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  BoxDecoration commonCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
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

  final List<Map<String, dynamic>> categories = [
    {"name": "Food", "color": 0xFFE74C3C, "amount": 1150.0, "percent": 36},
    {"name": "Transport", "color": 0xFF00A9FF, "amount": 680.0, "percent": 21},
    {"name": "Bills", "color": 0xFF00C48C, "amount": 520.0, "percent": 16},
    {"name": "Shopping", "color": 0xFFFF9800, "amount": 350.0, "percent": 12},
    {"name": "Others", "color": 0xFF9E9E9E, "amount": 147.0, "percent": 6},
  ];

  final List<Map<String, dynamic>> transactions = [
    {
      "title": "Starbucks Coffee",
      "tags": ["Food", "Today"],
      "amount": -8.75,
    },
    {
      "title": "Uber Ride",
      "tags": ["Transport", "Today"],
      "amount": -22.5,
    },
    {
      "title": "Whole Foods",
      "tags": ["Food", "Yesterday"],
      "amount": -156.8,
    },
    {
      "title": "Apple Music",
      "tags": ["Bills", "Yesterday"],
      "amount": -9.99,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _greetingHeader(),
            const SizedBox(height: 12),
            _summaryCard(),
            const SizedBox(height: 12),
            _spendingByCategoryCard(),
            const SizedBox(height: 12),
            _recentTransactionsCard(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statTile(
                    icon: CupertinoIcons.arrow_up_right,
                    label: "vs Last Month",
                    value: "+8.5%",
                    bg: const Color(0xFFE8F5E9),
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statTile(
                    icon: CupertinoIcons.calendar,
                    label: "Days Left",
                    value: "9 days",
                    bg: const Color(0xFFE8F5FE),
                    color: const Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _greetingHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Hello, Sheikh Rafi! 👋",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                "Track your expenses wisely",
                style: TextStyle(color: Color.fromARGB(151, 0, 0, 0)),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentPurple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentPurple),
          ),
          child: Icon(CupertinoIcons.plus, color: accentPurple),
        ),
      ],
    );
  }

  Widget _summaryCard() {
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
                  children: const [
                    Text(
                      "Total Spent This Month",
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "\৳2,847",
                      style: TextStyle(
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
            children: const [
              Expanded(
                child: Text(
                  "Budget: \৳3,500",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text("Remaining: \৳653", style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.81,
              minHeight: 8,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "81.3% used",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "9 days left",
                  style: TextStyle(
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
  }

  Widget _spendingByCategoryCard() {
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
                  color: lightBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: const Text("January 2025"),
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
                    categories.map((e) => Color(e["color"])).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: categories.map((c) => _catRow(c)).toList(),
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
              color: Color(c["color"]),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              c["name"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            "\৳${(c["amount"] as double).toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Text(
            "${c["percent"]}%",
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _recentTransactionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                "Recent Transactions",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Spacer(),
              Text(
                "View All",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...transactions.map((t) => _txnItem(t)).toList(),
        ],
      ),
    );
  }

  Widget _txnItem(Map<String, dynamic> t) {
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
              child: Icon(CupertinoIcons.cart, color: accentPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t["title"],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: List<String>.from(t["tags"])
                        .map(
                          (s) => Text(
                            s,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Text(
              _formatAmount(t["amount"] as double),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _amountColor(t["amount"] as double),
              ),
            ),
          ],
        ),
      ),
    );
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
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(double a) {
    final String val = a.abs().toStringAsFixed(2);
    return "${a < 0 ? "-" : "+"}৳$val";
  }

  static Color _amountColor(double a) {
    return a < 0 ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  DonutChartPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final double total = values.fold(0, (p, c) => p + c);
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
      final double sweep =
          (values[i] / (total == 0 ? 1 : total)) * 2 * 3.1415926535;
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
