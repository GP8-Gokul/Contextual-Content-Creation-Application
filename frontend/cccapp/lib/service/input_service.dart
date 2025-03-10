import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cccapp/service/root_api.dart';
import 'package:http/http.dart' as http;

class PDFService {
  static Future<String?> uploadPDFWithKeywords({
    required File pdf,
    required List<String> keywords,
    required String userId,
  }) async {
    try {
      final Uint8List pdfBytes = await pdf.readAsBytes();
      final String encodedPdf = base64Encode(pdfBytes);
      final Map<String, dynamic> body = {
        'userid': userId,
        'pdf': encodedPdf,
        'keywords': keywords,
      };

      final response = await http.post(
        Uri.parse('$url/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String studyPlanId = responseData['s_id'];

        return studyPlanId;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
