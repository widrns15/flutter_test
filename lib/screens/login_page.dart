import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final uri = Uri.parse('http://192.168.0.232:22111/api/auth/login');
    final body = {
      'username': _usernameController.text.trim(),
      'password': _passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(response.body);
      final data = responseBody['data'];

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data != null) {
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final expiresIn = data['expiresIn'];

        if (accessToken != null && refreshToken != null && expiresIn != null) {
          final prefs = await SharedPreferences.getInstance();
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final expiresAt = now + (expiresIn as int);

          await prefs.setString('accessToken', accessToken);
          await prefs.setString('refreshToken', refreshToken);
          await prefs.setInt('accessTokenExpiresAt', expiresAt);

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showError("토큰 정보가 유효하지 않습니다.");
        }
      } else {
        final errorMessage = responseBody['message'] ?? '로그인 실패';
        _showError(errorMessage);
      }
    } catch (e) {
      _showError("에러 발생: $e");
    }

    setState(() => _isSubmitting = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "아이디"),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? "아이디를 입력해주세요"
                            : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "비밀번호"),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? "비밀번호를 입력해주세요"
                            : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _login,
                child: Text(_isSubmitting ? "로그인 중..." : "로그인"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
