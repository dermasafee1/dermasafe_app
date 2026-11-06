import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://dermasafe.com.ua/api';

  static Future<Map<String, dynamic>> sendCode(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send_code.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyCode(String phone, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify_code.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getCard(String token) async {
    try {
      // Тепер передаємо токен прямо в посиланні ?token=...
      final response = await http.get(
        Uri.parse('$baseUrl/get_card.php?token=$token'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 401) {
        return {'status': 'error', 'message': 'Token expired or invalid'};
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      // Якщо сервер поверне помилку (не JSON), додаток не зависне
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }
}