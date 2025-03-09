import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:developer';

class PDFService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  /// Uploads PDF with keywords to the backend
  static Future<bool> uploadPDFWithKeywords({
    required File pdf,
    required List<String> keywords,
    required String userId,
  }) async {
    try {
      // Read the PDF file as bytes
      final Uint8List pdfBytes = await pdf.readAsBytes();

      // Convert bytes to base64 for sending as JSON
      final String encodedPdf = base64Encode(pdfBytes);

      // Create request body
      final Map<String, dynamic> body = {
        'userId': userId,
        'pdf': encodedPdf,
        'keywords': keywords,
      };

      // Send request to backend
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        log('PDF uploaded successfully');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        log('Response: $responseData');
        return true;
      } else {
        log('Error uploading PDF: ${response.statusCode}');
        log('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Exception when uploading PDF: $e');
      return false;
    }
  }
}
