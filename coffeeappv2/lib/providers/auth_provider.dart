import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final AuthService authService;

  String? token;
  User? user;

  bool isLoading = false;
  String? errorMessage;

  AuthProvider({
    required this.authService,
  });

  bool get isAuthenticated => token != null;

  // planV2.md ข้อ 56 Session 5 ชั่วโมงที่ 1: อ่าน Token ที่เคยบันทึกไว้ตอนเปิดแอป
  // เพื่อ Auto Login — ต้องเรียกครั้งเดียวตอน App เริ่มทำงาน (ดู SplashScreen)
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    final savedUserJson = prefs.getString(_userKey);

    if (savedToken != null && savedUserJson != null) {
      token = savedToken;
      user = User.fromJson(
        jsonDecode(savedUserJson) as Map<String, dynamic>,
      );
      notifyListeners();
    }
  }

  Future<bool> login(
    String email,
    String password,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await authService.login(
        email: email,
        password: password,
      );

      token = data['token'];
      user = User.fromJson(data['user']);

      await _saveSession();

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token!);
    await prefs.setString(_userKey, jsonEncode(user!.toJson()));
  }

  void logout() {
    token = null;
    user = null;
    notifyListeners();
    _clearSession();
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
