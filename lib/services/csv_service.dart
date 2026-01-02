import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/expense_model.dart';
import '../database/database_helper.dart';

class CsvService {
  static final CsvService instance = CsvService._init();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  CsvService._init();

  // Export expenses to CSV file for a specific user
  Future<Map<String, dynamic>> exportExpenses(int userId) async {
    try {
      // Get all expenses for the user
      final expenses = await _dbHelper.readAllExpenses(userId);

      if (expenses.isEmpty) {
        return {
          'success': false,
          'message': 'No expenses to export',
        };
      }

      // Prepare CSV data
      List<List<dynamic>> rows = [];
      
      // Add header row
      rows.add([
        'ID',
        'Amount',
        'Description',
        'Category',
        'Payment Method',
        'Date',
        'Notes',
        'Created At',
      ]);

      // Add data rows
      for (var expense in expenses) {
        rows.add([
          expense.id,
          expense.amount,
          expense.description,
          expense.category,
          expense.paymentMethod,
          expense.date.toIso8601String(),
          expense.notes ?? '',
          expense.createdAt.toIso8601String(),
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);

      // Get directory to save file - try external storage first (Downloads folder on Android)
      Directory? directory;
      
      // Try to get external storage directory (Downloads folder)
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to app documents directory
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // For iOS, use app documents directory
        directory = await getApplicationDocumentsDirectory();
      }
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'expenses_export_$timestamp.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV to file
      await file.writeAsString(csv);

      return {
        'success': true,
        'message': 'Expenses exported successfully',
        'filePath': file.path,
        'fileName': fileName,
        'count': expenses.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error exporting expenses: $e',
      };
    }
  }

  // Import expenses from CSV file for a specific user
  Future<Map<String, dynamic>> importExpenses(int userId) async {
    try {
      // Let user pick CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        return {
          'success': false,
          'message': 'No file selected',
        };
      }

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();

      // Parse CSV
      List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

      if (csvData.isEmpty || csvData.length < 2) {
        return {
          'success': false,
          'message': 'CSV file is empty or invalid',
        };
      }

      // Skip header row
      final dataRows = csvData.skip(1).toList();
      int importedCount = 0;
      int errorCount = 0;

      for (var row in dataRows) {
        try {
          // Validate row has enough columns
          if (row.length < 7) continue;

          // Create expense object (skip the ID column as it will be auto-generated)
          final expense = Expense(
            userId: userId,
            amount: double.parse(row[1].toString()),
            description: row[2].toString(),
            category: row[3].toString(),
            paymentMethod: row[4].toString(),
            date: DateTime.parse(row[5].toString()),
            notes: row[6].toString().isEmpty ? null : row[6].toString(),
          );

          // Insert into database
          await _dbHelper.createExpense(expense);
          importedCount++;
        } catch (e) {
          errorCount++;
          // Continue with next row
        }
      }

      return {
        'success': true,
        'message': 'Expenses imported successfully',
        'importedCount': importedCount,
        'errorCount': errorCount,
        'totalRows': dataRows.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error importing expenses: $e',
      };
    }
  }

  // Export expenses for a specific date range
  Future<Map<String, dynamic>> exportExpensesByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get expenses for the date range
      final expenses = await _dbHelper.readExpensesByDateRange(
        userId,
        startDate,
        endDate,
      );

      if (expenses.isEmpty) {
        return {
          'success': false,
          'message': 'No expenses found in the selected date range',
        };
      }

      // Prepare CSV data
      List<List<dynamic>> rows = [];
      
      // Add header row
      rows.add([
        'ID',
        'Amount',
        'Description',
        'Category',
        'Payment Method',
        'Date',
        'Notes',
        'Created At',
      ]);

      // Add data rows
      for (var expense in expenses) {
        rows.add([
          expense.id,
          expense.amount,
          expense.description,
          expense.category,
          expense.paymentMethod,
          expense.date.toIso8601String(),
          expense.notes ?? '',
          expense.createdAt.toIso8601String(),
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);

      // Get directory to save file
      final directory = await getApplicationDocumentsDirectory();
      final dateRange = '${startDate.toIso8601String().split('T')[0]}_to_${endDate.toIso8601String().split('T')[0]}';
      final fileName = 'expenses_export_$dateRange.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV to file
      await file.writeAsString(csv);

      return {
        'success': true,
        'message': 'Expenses exported successfully',
        'filePath': file.path,
        'fileName': fileName,
        'count': expenses.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error exporting expenses: $e',
      };
    }
  }

  // Get sample CSV template
  String getSampleCsv() {
    List<List<dynamic>> rows = [
      [
        'ID',
        'Amount',
        'Description',
        'Category',
        'Payment Method',
        'Date',
        'Notes',
        'Created At',
      ],
      [
        '(auto)',
        '1500.00',
        'Grocery Shopping',
        'Food',
        'Credit Card',
        DateTime.now().toIso8601String(),
        'Weekly groceries',
        DateTime.now().toIso8601String(),
      ],
      [
        '(auto)',
        '50.00',
        'Coffee',
        'Food',
        'Cash',
        DateTime.now().toIso8601String(),
        '',
        DateTime.now().toIso8601String(),
      ],
    ];

    return const ListToCsvConverter().convert(rows);
  }
}
