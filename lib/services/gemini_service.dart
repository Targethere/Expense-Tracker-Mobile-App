import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;

  GeminiService();

  Future<void> _initModel() async {
    if (_model != null) return;

    try {
      final apiKey = await rootBundle.loadString('assets/GEMINI_API_KEY.txt');
      _model = GenerativeModel(
        model: 'gemini-flash-lite-latest',
        apiKey: apiKey.trim(),
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topK: 32,
          topP: 1,
          maxOutputTokens: 1024,
        ),
      );
    } catch (e) {
      print('Error loading Gemini API key: $e');
    }
  }

  /// Extracts expense information from a receipt image
  /// Returns a map with extracted data or null if extraction fails
  Future<Map<String, dynamic>?> extractExpenseFromReceipt(
    String imagePath,
  ) async {
    await _initModel();
    if (_model == null) {
      print('Gemini model not initialized');
      return null;
    }

    try {
      // Read the image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Create the prompt for structured extraction
      final prompt = '''
Analyze this receipt image and extract expense information. Return ONLY a valid JSON object (no markdown, no code blocks) with the following structure:

{
  "amount": <number or null>,
  "description": "<string or null>",
  "category": "<string or null>",
  "date": "<YYYY-MM-DD or null>",
  "merchantName": "<string or null>",
  "confidence": <number 0-100>
}

Rules:
1. amount: Extract the total amount as a number (without currency symbols). If multiple amounts, use the TOTAL/FINAL amount.
2. description: Merchant name or brief description of the purchase (max 50 chars)
3. category: Choose ONE from: "Food & Dining", "Transportation", "Bills & Utilities", "Shopping", "Healthcare", "Entertainment". If unsure, return null.
4. date: Extract date in YYYY-MM-DD format. If not found, return null.
5. merchantName: The name of the store/restaurant/service provider
6. confidence: Your confidence level (0-100) in the extracted data

Important: 
- Return ONLY the JSON object, no other text
- If you cannot extract a field, set it to null
- Be conservative with category selection
- Ensure all string values are properly escaped for JSON

Example:
{"amount": 45.50, "description": "Starbucks", "category": "Food & Dining", "date": "2025-01-30", "merchantName": "Starbucks Coffee", "confidence": 85}
''';

      // Create content with image and prompt
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      // Generate response
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('No response from Gemini API');
      }

      // Parse the JSON response
      final jsonString = _cleanJsonResponse(response.text!);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Validate and return the response
      return _validateAndCleanResponse(jsonData);
    } catch (e) {
      print('Error extracting expense from receipt: $e');
      return null;
    }
  }

  /// Clean the response to extract pure JSON
  String _cleanJsonResponse(String response) {
    // Remove markdown code blocks if present
    String cleaned = response.trim();

    // Remove ```json or ``` markers
    cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');

    // Find the first { and last }
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }

    return cleaned.trim();
  }

  /// Validate and clean the extracted data
  Map<String, dynamic> _validateAndCleanResponse(Map<String, dynamic> data) {
    final validCategories = [
      "Food & Dining",
      "Transportation",
      "Bills & Utilities",
      "Shopping",
      "Healthcare",
      "Entertainment",
    ];

    // Clean and validate amount
    double? amount;
    if (data['amount'] != null) {
      if (data['amount'] is num) {
        amount = (data['amount'] as num).toDouble();
      } else if (data['amount'] is String) {
        amount = double.tryParse(data['amount'] as String);
      }
    }

    // Clean and validate category
    String? category = data['category'] as String?;
    if (category != null && !validCategories.contains(category)) {
      category = null; // Invalid category, set to null
    }

    // Clean description
    String? description = data['description'] as String?;
    if (description != null && description.length > 100) {
      description = description.substring(0, 100);
    }

    // Clean merchant name
    String? merchantName = data['merchantName'] as String?;
    if (merchantName != null && merchantName.length > 100) {
      merchantName = merchantName.substring(0, 100);
    }

    // Validate date format (YYYY-MM-DD)
    String? date = data['date'] as String?;
    if (date != null) {
      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!dateRegex.hasMatch(date)) {
        date = null;
      }
    }

    // Get confidence (default to 50 if not provided)
    int confidence = 50;
    if (data['confidence'] != null) {
      if (data['confidence'] is num) {
        confidence = (data['confidence'] as num).toInt();
      } else if (data['confidence'] is String) {
        confidence = int.tryParse(data['confidence'] as String) ?? 50;
      }
    }
    confidence = confidence.clamp(0, 100);

    return {
      'amount': amount,
      'description': description ?? merchantName,
      'category': category,
      'date': date,
      'merchantName': merchantName,
      'confidence': confidence,
    };
  }

  /// Test if the API key is valid
  Future<bool> testApiKey() async {
    await _initModel();
    if (_model == null) return false;

    try {
      final testPrompt = 'Say "OK" if you can read this.';
      final content = [Content.text(testPrompt)];
      final response = await _model!.generateContent(content);
      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      print('API key test failed: $e');
      return false;
    }
  }
}
