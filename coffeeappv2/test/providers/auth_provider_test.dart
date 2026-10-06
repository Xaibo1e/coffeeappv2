import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffeeappv2/providers/auth_provider.dart';
import 'package:coffeeappv2/services/auth_service.dart';

// Fake ที่ extend ของจริงเพื่อตัด HTTP ออก — plan.md ข้อ 47/48 (Login Success/Failure)
class _FakeAuthService extends AuthService {
  final bool shouldSucceed;
  _FakeAuthService({this.shouldSucceed = true});

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (shouldSucceed) {
      return {
        'token': 'fake-jwt-token',
        'user': {
          'id': 1,
          'firstname': 'Coffee',
          'lastname': 'Student',
          'email': email,
        },
      };
    }
    throw Exception('Email and password does not match');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthProvider', () {
    test('login success stores token/user and clears error (Demo 1)', () async {
      final auth = AuthProvider(authService: _FakeAuthService());

      final result = await auth.login('student@example.com', '123456');

      expect(result, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.token, 'fake-jwt-token');
      expect(auth.user?.email, 'student@example.com');
      expect(auth.errorMessage, isNull);
      expect(auth.isLoading, isFalse);
    });

    test('login failure sets errorMessage and stays unauthenticated (Demo 2)', () async {
      final auth = AuthProvider(authService: _FakeAuthService(shouldSucceed: false));

      final result = await auth.login('student@example.com', 'wrong-password');

      expect(result, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorMessage, contains('does not match'));
    });

    test('logout clears token and user', () async {
      final auth = AuthProvider(authService: _FakeAuthService());
      await auth.login('student@example.com', '123456');

      auth.logout();

      expect(auth.isAuthenticated, isFalse);
      expect(auth.token, isNull);
      expect(auth.user, isNull);
    });

    // planV2.md ข้อ 56 Session 5 ชั่วโมงที่ 1: Persist Login / Auto Login
    test('restoreSession restores a session saved by a previous login', () async {
      final loggedIn = AuthProvider(authService: _FakeAuthService());
      await loggedIn.login('student@example.com', '123456');

      // ตัวแทน Provider ใหม่ที่ถูกสร้างตอนเปิดแอปใหม่ (cold start)
      final restored = AuthProvider(authService: _FakeAuthService());
      await restored.restoreSession();

      expect(restored.isAuthenticated, isTrue);
      expect(restored.token, 'fake-jwt-token');
      expect(restored.user?.email, 'student@example.com');
    });

    test('restoreSession stays unauthenticated when nothing was saved', () async {
      final auth = AuthProvider(authService: _FakeAuthService());

      await auth.restoreSession();

      expect(auth.isAuthenticated, isFalse);
    });

    // planV2.md ข้อ 57 Session 6 Test Cases: "Logout แล้วเปิดแอปใหม่"
    test('logout removes the persisted session so restoreSession finds nothing', () async {
      final loggedIn = AuthProvider(authService: _FakeAuthService());
      await loggedIn.login('student@example.com', '123456');

      loggedIn.logout();
      // logout() ลบ session แบบ fire-and-forget (ไม่ await ภายใน) — รอ microtask
      // ให้ _clearSession() ทำงานจบก่อนตรวจสอบ
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final restored = AuthProvider(authService: _FakeAuthService());
      await restored.restoreSession();

      expect(restored.isAuthenticated, isFalse);
    });
  });
}