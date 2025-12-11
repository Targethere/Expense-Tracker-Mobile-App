import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Color accentPurple = const Color(0xFF8A5BFF);
  final Color accentBlue = const Color(0xFF00A9FF);
  final Color accentGreen = const Color(0xFF00C48C);
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

  final List<String> suggestions = [
    "Transport costs over 150",
    "All food purchases last week",
    "Credit card expenses today",
    "AI Processing...",
  ];

  final List<String> quickFilters = [
    "This Week",
    "This Month",
    "Food",
    "Over \৳20",
  ];

  final List<Map<String, dynamic>> results = [
    {
      "title": "Starbucks Coffee",
      "tags": ["Food", "Card"],
      "date": DateTime(2025, 1, 30),
      "amount": -12.5,
    },
    {
      "title": "Starbucks Coffee",
      "tags": ["Food", "Credit"],
      "date": DateTime(2025, 1, 30),
      "amount": -12.5,
    },
    {
      "title": "Coffee Bean & Tea",
      "tags": ["Food", "Cash"],
      "date": DateTime(2025, 1, 29),
      "amount": -8.75,
    },
    {
      "title": "Local Coffee Shop",
      "tags": ["Food", "Digital"],
      "date": DateTime(2025, 1, 28),
      "amount": -6.5,
    },
    {
      "title": "Dunkin' Donuts",
      "tags": ["Food", "Card"],
      "date": DateTime(2025, 1, 27),
      "amount": -4.99,
    },
    {
      "title": "Cafe Mocha",
      "tags": ["Food", "Credit"],
      "date": DateTime(2025, 1, 25),
      "amount": -11.25,
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Show coffee expenses this month",
                      prefixIcon: const Icon(CupertinoIcons.search),
                      filled: true,
                      fillColor: lightBg,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accentPurple, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Try natural language:",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions
                        .map(
                          (s) => _chip(s, accentBlue, const Color(0xFFE8F5FE)),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Filters",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(
                        quickFilters[0],
                        accentPurple,
                        const Color(0xFFF3E8FF),
                      ),
                      _chip(
                        quickFilters[1],
                        accentPurple,
                        const Color(0xFFEDE7FF),
                      ),
                      _chip(
                        quickFilters[2],
                        accentBlue,
                        const Color(0xFFE8F5FE),
                      ),
                      _chip(
                        quickFilters[3],
                        accentGreen,
                        const Color(0xFFE8F5E9),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Text(
                  "8 Results",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 6),
                _SmallBadge(text: "Filtered"),
                Spacer(),
                Icon(CupertinoIcons.slider_horizontal_3, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 8),
            ...results.map((r) => _resultItem(r)).toList(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Total Coffee Expenses",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "8 transactions this month",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatAmount(_totalAmount()),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _amountColor(_totalAmount()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withOpacity(0.8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _resultItem(Map<String, dynamic> r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: commonCardDecoration(),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.restaurant, color: accentPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r["title"],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...List<String>.from(r["tags"])
                          .map(
                            (t) => Text(
                              t,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          )
                          .toList(),
                      const Text("•", style: TextStyle(color: Colors.black26)),
                      Text(
                        _formatDate(r["date"]),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              _formatAmount(r["amount"] as double),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _amountColor(r["amount"] as double),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
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
    ];
    return "${d.year}-${months[d.month - 1]}-${d.day.toString().padLeft(2, '0')}";
  }

  static String _formatAmount(double a) {
    final String sign = a < 0 ? "-" : "+";
    final String val = a.abs().toStringAsFixed(2);
    return "$sign\৳$val";
  }

  static Color _amountColor(double a) {
    return a < 0 ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);
  }

  double _totalAmount() {
    double sum = 0;
    for (final r in results) {
      sum += (r["amount"] as double);
    }
    return sum;
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  const _SmallBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5FE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF0277BD),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
