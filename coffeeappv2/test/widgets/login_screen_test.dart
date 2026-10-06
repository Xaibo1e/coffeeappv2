import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coffeeappv2/providers/auth_provider.dart';
import 'package:coffeeappv2/screens/login_screen.dart';
import 'package:coffeeappv2/services/auth_service.dart';

class _FailingAuthService extends AuthService {
  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    throw Exception('Email and password does not match');
  }
}

void main() {
  // plan.md ข้อ 48 (Demo 2 — Login Failure): กด LOGIN แล้ว UI ต้องแสดง
  // errorMessage จาก AuthProvider ให้ผู้ใช้เห็น
  testWidgets('shows the AuthProvider error message after a failed login', (tester) async {
    final auth = AuthProvider(authService: _FailingAuthService());

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Email and password does not match'), findsNothing);

    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Email and password does not match'), findsOneWidget);
  });

  testWidgets('email/password fields are prefilled with the demo user', (tester) async {
    final auth = AuthProvider(authService: _FailingAuthService());

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('student@example.com'), findsOneWidget);
  });
}