import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProtectedRoute extends StatefulWidget {
  final Widget child;
  const ProtectedRoute({required this.child, super.key});

  @override
  State<ProtectedRoute> createState() => _ProtectedRouteState();
}

class _ProtectedRouteState extends State<ProtectedRoute> {
  bool _checking = true;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final expiresAt = prefs.getInt('accessTokenExpiresAt');
    final refreshToken = prefs.getString('refreshToken');

    if (token == null || expiresAt == null) {
      _redirectToLogin();
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final isExpired = now >= expiresAt;

    if (isExpired && refreshToken != null) {
      final success = await _refreshToken(refreshToken);
      if (success) {
        await _loadUserProfile();
        setState(() {
          _isValid = true;
          _checking = false;
        });
        return;
      } else {
        _redirectToLogin();
        return;
      }
    }

    final valid = await _validateToken(token);
    if (valid) {
      await _loadUserProfile();
      setState(() {
        _isValid = true;
        _checking = false;
      });
    } else {
      _redirectToLogin();
    }
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
      final response = await http.patch(
        Uri.parse('http://192.168.0.232:22111/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        final prefs = await SharedPreferences.getInstance();
        final accessToken = data?['accessToken'];
        final newRefreshToken = data?['refreshToken'];
        final expiresIn = (data?['expiresIn'] as num?)?.toInt();

        if (accessToken != null &&
            newRefreshToken != null &&
            expiresIn != null) {
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final expiresAt = now + expiresIn;

          await prefs.setString('accessToken', accessToken);
          await prefs.setString('refreshToken', newRefreshToken);
          await prefs.setInt('accessTokenExpiresAt', expiresAt);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://192.168.0.232:22111/api/auth/me"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data != null) {
          await prefs.setString('userProfile', jsonEncode(data));
        }
      }
    } catch (_) {}
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isValid ? widget.child : const SizedBox.shrink();
  }
}
