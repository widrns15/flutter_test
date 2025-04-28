import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/post.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({required this.postId, super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  int? _myUserId;
  bool _isLoading = true;
  bool _hasRequested = false; // ✅ 요청 후 버튼 비활성화용

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadMyUserId();
    await _fetchPostDetail();
  }

  Future<void> _loadMyUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileStr = prefs.getString('userProfile');

    if (userProfileStr != null) {
      final userProfile = jsonDecode(userProfileStr);
      _myUserId = userProfile['id'] as int?;
    }
  }

  Future<void> _fetchPostDetail() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.232:22111/api/post/${widget.postId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final postData = body['data'];

        setState(() {
          _post = Post.fromJson(postData);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showMessage('게시글 상세 불러오기 실패');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('오류 발생: $e');
    }
  }

  Future<void> _sendMatchingRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null || _post == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.232:22111/api/matching'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"postId": _post!.id, "message": "매칭 요청합니다."}),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        setState(() {
          _hasRequested = true; // ✅ 요청 완료 표시
        });
        _showMessage("매칭 요청을 보냈습니다!");
      } else {
        if (!mounted) return;
        final error = jsonDecode(response.body);
        final message = error['message'] ?? "요청 실패";
        _showMessage(message);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('요청 중 오류 발생: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool get isMyPost {
    if (_post == null || _post!.user.id == null || _myUserId == null)
      return false;
    return _post!.user.id == _myUserId;
  }

  String formatDateRange(DateTime start, DateTime end) {
    final s = DateFormat('yyyy-MM-dd').format(start);
    final e = DateFormat('yyyy-MM-dd').format(end);
    return "$s ~ $e";
  }

  String formatPrice(int price) {
    return NumberFormat("#,###").format(price);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _post == null) {
      return Scaffold(
        appBar: AppBar(title: Text("게시글 상세")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("게시글 상세"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "[${_post!.type}] ${_post!.desc}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("지역: ${_post!.region}"),
            Text("기간: ${formatDateRange(_post!.startedAt, _post!.endedAt)}"),
            Text("요금: ${formatPrice(_post!.pay)}원"),
            SizedBox(height: 12),
            Text("소개", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_post!.desc, style: TextStyle(fontSize: 16)),

            if (_post!.user.pets.isNotEmpty) ...[
              SizedBox(height: 12),
              Text("보유 반려동물", style: TextStyle(fontWeight: FontWeight.bold)),
              ..._post!.user.pets.map(
                (pet) => ListTile(
                  leading:
                      pet.image.isNotEmpty
                          ? Image.network(
                            "http://192.168.0.232:22111${pet.image}",
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                          : Icon(Icons.pets),
                  title: Text("${pet.name} (${pet.type})"),
                  subtitle:
                      pet.description != null ? Text(pet.description!) : null,
                ),
              ),
            ],

            Spacer(),

            if (!isMyPost)
              ElevatedButton(
                onPressed: _hasRequested ? null : _sendMatchingRequest,
                child: Text(_hasRequested ? "요청 완료" : "매칭 요청하기"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
