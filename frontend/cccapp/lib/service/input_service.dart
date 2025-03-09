import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';

class PDFService {
  static const String baseUrl = 'http://127.0.0.1:5000';
  static const String wsBaseUrl = 'ws://127.0.0.1:5000';

  // Map to store WebSocket connections by studyPlanId
  static final Map<String, WebSocketChannel> _activeConnections = {};

  /// Uploads PDF with keywords to the backend and establishes a WebSocket connection
  /// to receive the processed output when ready
  static Future<String?> uploadPDFWithKeywords({
    required File pdf,
    required List<String> keywords,
    required String userId,
    required Function(Map<String, dynamic>) onOutputReady,
    required Function(String) onError,
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

        // Extract the studyPlanId from the response
        final String studyPlanId = responseData['studyPlanId'];

        // Establish WebSocket connection to receive updates
        _connectToWebSocket(
          studyPlanId: studyPlanId,
          onOutputReady: onOutputReady,
          onError: onError,
        );

        return studyPlanId;
      } else {
        log('Error uploading PDF: ${response.statusCode}');
        log('Response: ${response.body}');
        onError('Failed to upload PDF: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception when uploading PDF: $e');
      onError('Exception when uploading PDF: $e');
      return null;
    }
  }

  /// Establishes a WebSocket connection to receive updates for a specific studyPlanId
  static void _connectToWebSocket({
    required String studyPlanId,
    required Function(Map<String, dynamic>) onOutputReady,
    required Function(String) onError,
  }) {
    try {
      // Create WebSocket connection
      final channel = WebSocketChannel.connect(
        Uri.parse('$wsBaseUrl/ws/$studyPlanId'),
      );

      // Store the connection
      _activeConnections[studyPlanId] = channel;

      // Listen for messages
      channel.stream.listen(
        (message) {
          log('Received WebSocket message: $message');

          try {
            final data = jsonDecode(message);

            // Check if this is the final output
            if (data['status'] == 'completed') {
              onOutputReady(data);

              // Close the connection as we've received the final output
              closeConnection(studyPlanId);
            }
          } catch (e) {
            log('Error processing WebSocket message: $e');
          }
        },
        onError: (error) {
          log('WebSocket error: $error');
          onError('WebSocket error: $error');
          _activeConnections.remove(studyPlanId);
        },
        onDone: () {
          log('WebSocket connection closed');
          _activeConnections.remove(studyPlanId);
        },
      );
    } catch (e) {
      log('Error connecting to WebSocket: $e');
      onError('Error connecting to WebSocket: $e');
    }
  }

  /// Manually close a WebSocket connection
  static void closeConnection(String studyPlanId) {
    final connection = _activeConnections[studyPlanId];
    if (connection != null) {
      connection.sink.close();
      _activeConnections.remove(studyPlanId);
      log('Closed WebSocket connection for study plan: $studyPlanId');
    }
  }

  /// Manually check the status of a specific study plan
  /// This is a fallback method if WebSockets aren't available
  static Future<Map<String, dynamic>?> checkStudyPlanStatus(
      String studyPlanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status/$studyPlanId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        log('Error checking study plan status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception when checking study plan status: $e');
      return null;
    }
  }
}
