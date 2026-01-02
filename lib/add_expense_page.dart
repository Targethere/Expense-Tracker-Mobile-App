import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'models/expense_model.dart';
import 'providers/expense_provider.dart';
import 'providers/auth_provider.dart';
import 'services/gemini_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // State
  String? selectedCategory;
  String? selectedPaymentMethod = "Cash";
  DateTime selectedDate = DateTime.now();
  XFile? scannedImage;
  bool _isSubmitting = false;
  bool _isScanning = false;

  // Gemini Service
  final GeminiService _geminiService = GeminiService();

  // Data (omitted for brevity, assume they are still here)
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

  final List<Map<String, dynamic>> paymentOptionMethods = [
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
    notesController.dispose();
    super.dispose();
  }

  // Common card decoration (unchanged)
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

  // ==================== SCANNING LOGIC START ====================

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageAndScan() async {
    // Dynamic: Show a dialog to choose between Camera or Gallery
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Receipt Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          scannedImage = image; // Store the file reference
        });
        _scanAndExtractDetails(image.path);
      }
    }
  }

  Future<void> _scanAndExtractDetails(String imagePath) async {
    if (!mounted) return;

    setState(() {
      _isScanning = true;
    });

    // Show processing message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Analyzing receipt with AI...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      // Call Gemini API to extract expense data
      final extractedData = await _geminiService.extractExpenseFromReceipt(
        imagePath,
      );

      if (!mounted) return;

      // Hide the processing message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (extractedData != null) {
        setState(() {
          _isScanning = false;

          // Populate amount if available
          if (extractedData['amount'] != null) {
            amountController.text = extractedData['amount'].toString();
          }

          // Populate description if available
          if (extractedData['description'] != null &&
              extractedData['description'].toString().isNotEmpty) {
            descriptionController.text = extractedData['description'];
          }

          // Set category if available and valid
          if (extractedData['category'] != null) {
            selectedCategory = extractedData['category'];
          }

          // Parse and set date if available
          if (extractedData['date'] != null) {
            try {
              selectedDate = DateTime.parse(extractedData['date']);
            } catch (e) {
              // Keep current date if parsing fails
            }
          }

          // Add merchant name to notes if available
          if (extractedData['merchantName'] != null &&
              extractedData['merchantName'].toString().isNotEmpty) {
            final merchantNote = 'Merchant: ${extractedData['merchantName']}';
            if (notesController.text.isEmpty) {
              notesController.text = merchantNote;
            } else {
              notesController.text = '${notesController.text}\n$merchantNote';
            }
          }
        });

        // Show success message with confidence level
        final confidence = extractedData['confidence'] ?? 50;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Receipt scanned! Confidence: $confidence%\nPlease verify the details.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: confidence >= 70
                ? const Color(0xFF00C48C)
                : const Color(0xFFFF9800),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        setState(() {
          _isScanning = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Could not extract data from receipt. Please enter manually.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });

      // Hide the processing message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==================== SCANNING LOGIC END ====================

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildScanReceiptCard(),
            const SizedBox(height: 12),
            buildAmountCard(),
            const SizedBox(height: 12),
            buildDescriptionCard(),
            const SizedBox(height: 12),
            buildCategoryCard(),
            const SizedBox(height: 12),
            buildDateAndPaymentRow(),
            const SizedBox(height: 12),
            buildNotesCard(),
            const SizedBox(height: 30),
            buildAddExpenseButton(),
          ],
        ),
      ),
    );
  }

  // ==================== Scan Receipt Card (Updated) ====================
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
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
              onPressed: _isScanning ? null : _pickImageAndScan,
              icon: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF8A5BFF),
                        ),
                      ),
                    )
                  : const Icon(Icons.camera_alt_outlined),
              label: Text(
                _isScanning
                    ? "Scanning..."
                    : (scannedImage != null
                          ? "Rescan Receipt"
                          : "Scan Receipt"),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFF8A5BFF)),
                foregroundColor: const Color(0xFF8A5BFF),
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
              hintText: "0.00",
              filled: true,
              fillColor: Theme.of(context).canvasColor,
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
              hintText: "What did you buy?",
              filled: true,
              fillColor: Theme.of(context).canvasColor,
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
          GridView.builder(
            itemCount: categories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
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
                        ? Theme.of(context).canvasColor
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

  // ==================== Date and Payment Row ====================
  Widget buildDateAndPaymentRow() {
    return Row(
      children: [
        Expanded(child: buildDateCard()),
        const SizedBox(width: 12),
        Expanded(child: buildPaymentMethodCard()),
      ],
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "${selectedDate.day} ${_monthName(selectedDate.month)}, ${selectedDate.year}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Payment Method Card ====================
  Widget buildPaymentMethodCard() {
    final method = paymentOptionMethods.firstWhere(
      (m) => m["name"] == selectedPaymentMethod,
      orElse: () => paymentOptionMethods[0],
    );
    return GestureDetector(
      onTap: _showPaymentMethodBottomSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: commonCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(method["icon"], size: 20, color: Color(method["color"])),
                const SizedBox(width: 8),
                Text(
                  method["name"],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: paymentOptionMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentOptionMethods[index];
                  final isSelected = selectedPaymentMethod == method["name"];
                  return ListTile(
                    leading: Icon(
                      method["icon"],
                      color: Color(method["color"]),
                    ),
                    title: Text(method["name"]),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF8A5BFF))
                        : null,
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = method["name"];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Notes Card ====================
  Widget buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notes (optional)",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Add any additional notes...",
              filled: true,
              fillColor: Theme.of(context).canvasColor,
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

  // ==================== Add Expense Button ====================
  Widget buildAddExpenseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A3AFF),
          disabledBackgroundColor: const Color(0xFF4A3AFF).withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.15),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
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

  // Validation method
  String? _validateInputs() {
    // Validate amount
    if (amountController.text.trim().isEmpty) {
      return 'Please enter an amount';
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount > 999999999) {
      return 'Amount is too large';
    }

    // Validate category
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      return 'Please select a category';
    }

    // Validate payment method
    if (selectedPaymentMethod == null || selectedPaymentMethod!.isEmpty) {
      return 'Please select a payment method';
    }

    // Validate description (optional but trim)
    final description = descriptionController.text.trim();
    if (description.length > 200) {
      return 'Description is too long (max 200 characters)';
    }

    // Validate notes (optional but trim)
    final notes = notesController.text.trim();
    if (notes.length > 500) {
      return 'Notes are too long (max 500 characters)';
    }

    return null; // All validations passed
  }

  // Save expense method with full validation
  Future<void> _saveExpense() async {
    // Prevent multiple submissions
    if (_isSubmitting) return;

    // Validate inputs
    final validationError = _validateInputs();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Parse amount
      final amount = double.parse(amountController.text.trim());

      // Get description (use category if empty)
      final description = descriptionController.text.trim().isEmpty
          ? selectedCategory!
          : descriptionController.text.trim();

      // Get notes (can be null)
      final notes = notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim();

      // Get current user ID from auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUserId;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        }
        return;
      }

      // Create expense object
      final expense = Expense(
        userId: userId,
        amount: amount,
        description: description,
        category: selectedCategory!,
        paymentMethod: selectedPaymentMethod!,
        date: selectedDate,
        notes: notes,
      );

      // Save to database via provider
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      final savedExpense = await expenseProvider.addExpense(expense);

      if (savedExpense != null) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Expense added successfully! ৳${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF00C48C),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          // Clear form after successful save
          _clearForm();
        }
      } else {
        throw Exception('Failed to save expense');
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      // Reset submitting state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Clear form after successful submission
  void _clearForm() {
    amountController.clear();
    descriptionController.clear();
    notesController.clear();
    setState(() {
      selectedCategory = null;
      selectedPaymentMethod = "Cash";
      selectedDate = DateTime.now();
      scannedImage = null;
    });
  }
}

// Global helper function for month name (unchanged)
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
