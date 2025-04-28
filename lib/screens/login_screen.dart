import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    final expiresAt = prefs.getInt('accessTokenExpiresAt');

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final isExpired = expiresAt == null || now >= expiresAt;

    if (accessToken != null && !isExpired) {
      final valid = await _validateToken(accessToken);
      if (valid) return _goToHome();
    }

    if (refreshToken != null) {
      final success = await _refreshToken(refreshToken);
      if (success) return _goToHome();
    }

    setState(() => _checking = false);
  }

  Future<bool> _validateToken(String token) async {
    try {
      final res = await http.get(
        Uri.parse("http://192.168.0.232:22111/api/auth/me"),
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _refreshToken(String refreshToken) async {
    try {
      final res = await http.patch(
        Uri.parse('http://192.168.0.232:22111/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body)['data'];
        final accessToken = data?['accessToken'];
        final newRefreshToken = data?['refreshToken'];
        final expiresIn = data?['expiresIn'];

        if (accessToken != null &&
            newRefreshToken != null &&
            expiresIn != null) {
          final prefs = await SharedPreferences.getInstance();
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final expiresAt = now + (expiresIn as int);
          await prefs.setString('accessToken', accessToken);
          await prefs.setString('refreshToken', newRefreshToken);
          await prefs.setInt('accessTokenExpiresAt', expiresAt);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  void _goToLogin() => Navigator.pushNamed(context, '/login');
  void _goToRegister() => Navigator.pushNamed(context, '/register');
  void _goToHome() => Navigator.pushReplacementNamed(context, '/home');

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("개인정보처리방침"),
            content: SingleChildScrollView(
              child: Text("여기에 개인정보처리방침 내용을 표시하거나 링크로 연결할 예정입니다."),
            ),
            actions: [
              TextButton(
                child: Text("닫기"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'EveryPet',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _goToLogin(),
              child: Text('로그인'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _goToRegister(),
              child: Text('회원가입'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 24),
            TextButton(
              onPressed: () => _showPrivacyPolicy(context),
              child: Text(
                "개인정보처리방침",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
