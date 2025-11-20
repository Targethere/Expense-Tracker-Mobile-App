import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // State
  String? selectedCategory;
  String? selectedPaymentMethod;
  DateTime selectedDate = DateTime.now();

  // Category data
  final List<Map<String, dynamic>> categories = [
    {"name": "Food & Dining", "icon": CupertinoIcons.cart, "color": 0xFF8A5BFF},
    {"name": "Transportation", "icon": CupertinoIcons.car, "color": 0xFF00A9FF},
    {
      "name": "Bills & Utilities",
      "icon": CupertinoIcons.bolt,
      "color": 0xFFFF9800,
    },
    {"name": "Shopping", "icon": CupertinoIcons.bag, "color": 0xFF00C48C},
    {"name": "Healthcare", "icon": CupertinoIcons.heart, "color": 0xFFE91E63},
    {
      "name": "Entertainment",
      "icon": CupertinoIcons.game_controller,
      "color": 0xFF673AB7,
    },
  ];

  // Payment methods data
  final List<Map<String, dynamic>> paymentMethods = [
    {"name": "Cash", "icon": CupertinoIcons.money_dollar, "color": 0xFF8A5BFF},
    {"name": "Card", "icon": CupertinoIcons.creditcard, "color": 0xFF00A9FF},
    {
      "name": "Bank Transfer",
      "icon": CupertinoIcons.building_2_fill,
      "color": 0xFFFF9800,
    },
    {
      "name": "Mobile Banking",
      "icon": CupertinoIcons.phone_arrow_up_right,
      "color": 0xFF00C48C,
    },
    {"name": "Wallet", "icon": CupertinoIcons.briefcase, "color": 0xFFE91E63},
    {"name": "Other", "icon": CupertinoIcons.ellipsis, "color": 0xFF673AB7},
  ];

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Common card decoration (white card with shadow)
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // const use kora better
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildScanReceiptCard(),
            const SizedBox(height: 12),
            buildAmountCard(),
            const SizedBox(height: 12),
            buildCategoryCard(),
            const SizedBox(height: 12),
            buildDescriptionCard(),
            const SizedBox(height: 12),
            buildDateCard(),
            const SizedBox(height: 12),
            buildPaymentMethodCard(),
            const SizedBox(height: 12),
            buildAddExpenseButton(),
          ],
        ),
      ),
    );
  }

  // ==================== Scan Receipt Card ====================
  Widget buildScanReceiptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8A5BFF), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 28,
              color: Color(0xFF8A5BFF),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Scan Receipt",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            "Use AI to automatically extract expense details",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: later camera/gallery add korbo
              },
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text("Scan Receipt"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFF8A5BFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Amount Card ====================
  Widget buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Amount *",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "৳",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              hintText: "45", // demo value on background
              filled: true,
              fillColor: Colors.white,
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
                borderSide: const BorderSide(
                  color: Color(0xFF8A5BFF),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Category Card ====================
  Widget buildCategoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Category *",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // list/grid of categories
          GridView.builder(
            itemCount: categories.length,
            shrinkWrap: true, // scroll na, card er vitorei thakbe
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 column
              childAspectRatio: 3.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final bool isSelected = selectedCategory == cat["name"];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = cat["name"];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: !isSelected
                        ? const Color(0xFFF9F9F9)
                        : Color(cat["color"]).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Color(cat["color"])
                          : const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(cat["icon"], size: 20, color: Color(cat["color"])),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat["name"],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== Description Card ====================
  Widget buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Description (optional)",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: "Whole Foods Market",
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
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
                borderSide: const BorderSide(
                  color: Color(0xFF8A5BFF),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Date Card ====================
  Widget buildDateCard() {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: commonCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Date",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                "${selectedDate.day} ${_monthName(selectedDate.month)}, ${selectedDate.year}",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Payment Method Card ====================
  Widget buildPaymentMethodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment Method *",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            itemCount: paymentMethods.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 column, category er moto
              childAspectRatio: 3.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final method = paymentMethods[index];
              final bool isSelected = selectedPaymentMethod == method["name"];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = method["name"];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: !isSelected
                        ? const Color(0xFFF9F9F9)
                        : Color(method["color"]).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Color(method["color"])
                          : const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        method["icon"],
                        size: 20,
                        color: Color(method["color"]),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          method["name"],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== Add Expense Button ====================
  Widget buildAddExpenseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Submit expense to database later
          // ekhane validation + save logic add korte parba
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A3AFF), // same purple tone
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.15),
        ),
        child: const Text(
          "Add Expense",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Eta global helper function hishebe thakbe
String _monthName(int m) {
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
  return months[m - 1];
}
