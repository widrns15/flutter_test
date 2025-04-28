import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _authCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regionController = TextEditingController();

  bool _isSubmitting = false;
  bool _isEmailVerified = false;
  String? _emailVerifyMessage;
  bool _codeRequested = false;
  DateTime? _codeRequestedAt;

  Future<void> _sendEmailCode() async {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      setState(() {
        _emailVerifyMessage = "유효한 이메일을 입력해주세요.";
      });
      return;
    }

    final response = await http.post(
      Uri.parse("http://192.168.0.232:22111/api/auth/email/send"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "type": "register"}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        _codeRequested = true;
        _codeRequestedAt = DateTime.now();
        _emailVerifyMessage = "인증 코드가 전송되었습니다.";
      });
    } else {
      setState(() {
        _emailVerifyMessage = "인증 코드 전송 실패: ${response.body}";
      });
    }
  }

  Future<void> _verifyEmailCode() async {
    final email = _emailController.text.trim();
    final code = _authCodeController.text.trim();

    if (!_codeRequested || _codeRequestedAt == null) {
      setState(() {
        _emailVerifyMessage = "먼저 인증 요청을 해주세요.";
      });
      return;
    }

    final now = DateTime.now();
    final isExpired = now.difference(_codeRequestedAt!).inMinutes >= 5;
    if (isExpired) {
      setState(() {
        _emailVerifyMessage = "인증 코드가 만료되었습니다. 다시 요청해주세요.";
        _isEmailVerified = false;
      });
      return;
    }

    if (code.isEmpty) {
      setState(() {
        _emailVerifyMessage = "인증 코드를 입력해주세요.";
        _isEmailVerified = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse("http://192.168.0.232:22111/api/auth/email/verify"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "code": code}),
    );

    final result = jsonDecode(response.body);
    final verified = result['data']?['verified'] == true;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        verified) {
      setState(() {
        _isEmailVerified = true;
        _emailVerifyMessage = "이메일 인증 완료";
      });
    } else {
      setState(() {
        _isEmailVerified = false;
        _emailVerifyMessage = "인증 실패: 인증 코드가 유효하지 않습니다.";
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEmailVerified) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("이메일 인증을 완료해주세요")));
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await http.post(
      Uri.parse('http://192.168.0.232:22111/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": _usernameController.text.trim(),
        "password": _passwordController.text.trim(),
        "email": _emailController.text.trim(),
        "phoneNumber": _phoneController.text.trim(),
        "region": _regionController.text.trim(),
        "nickname": _nicknameController.text.trim(),
        "profileImageUrl": "",
      }),
    );

    setState(() => _isSubmitting = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("회원가입 완료")));
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      try {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? "회원가입 실패";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } catch (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("회원가입 실패")));
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _authCodeController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "아이디"),
                validator: (val) => val!.isEmpty ? "아이디를 입력해주세요" : null,
              ),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: "닉네임"),
                validator: (val) => val!.isEmpty ? "닉네임을 입력해주세요" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "이메일",
                  suffixIcon: TextButton(
                    onPressed: _sendEmailCode,
                    child: Text("인증 요청"),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "이메일을 입력해주세요";
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(val)) return "이메일 형식이 올바르지 않습니다";
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _authCodeController,
                      decoration: InputDecoration(labelText: "인증 코드"),
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton(onPressed: _verifyEmailCode, child: Text("확인")),
                ],
              ),
              if (_emailVerifyMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _emailVerifyMessage!,
                    style: TextStyle(
                      color: _isEmailVerified ? Colors.green : Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "비밀번호"),
                validator: (val) => val!.length < 6 ? "6자 이상 입력해주세요" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "전화번호"),
                validator: (val) => val!.isEmpty ? "전화번호를 입력해주세요" : null,
              ),
              TextFormField(
                controller: _regionController,
                decoration: InputDecoration(labelText: "지역"),
                validator: (val) => val!.isEmpty ? "지역을 입력해주세요" : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _register,
                child: Text(_isSubmitting ? "처리 중..." : "회원가입"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
