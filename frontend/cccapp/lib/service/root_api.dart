import 'dart:convert';
import 'package:http/http.dart' as http;

const url = 'https://127.0.0.1:3000';
dynamic userId;
dynamic userName;

Future<List<Map<String, dynamic>>> fetchdata(tableName, userId) async {
  final response = await http.post(
    Uri.parse('${url}select'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'table': tableName}),
  );

  if (response.statusCode == 200) {
    return [
      {'id': 1, 'value': 'example1'},
      {'id': 2, 'value': 'example2'},
      {'id': 3, 'value': 'example3'}
    ];
  } else {
    throw Exception('Failed to load data');
  }
}
