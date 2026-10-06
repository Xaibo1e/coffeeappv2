import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Backend ตอบ HTTP 200 เสมอไม่ว่าสำเร็จหรือผิดพลาด (ดู backendapi.md ข้อ 2)
    // ต้องเช็ค field `status` ในตัว body แทน statusCode
    if (data['status'] == 'ok') {
      return data;
    }

    throw Exception(
      data['message']?.toString() ?? 'Login failed',
    );
  }
}