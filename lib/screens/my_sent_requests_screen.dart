import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/post.dart';
import 'post_detail_screen.dart';

class MySentRequestsScreen extends StatefulWidget {
  @override
  State<MySentRequestsScreen> createState() => _MySentRequestsScreenState();
}

class _MySentRequestsScreenState extends State<MySentRequestsScreen> {
  List<Post> _sentRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSentRequests();
  }

  Future<void> _fetchSentRequests() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.0.232:22111/api/mypage/matching/requested'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final dataList = body['data'];

      if (dataList != null && dataList is List) {
        final posts =
            dataList
                .map(
                  (item) => Post.fromJson(item['post']),
                ) // 🔥 item['post']만 파싱
                .toList();

        setState(() {
          _sentRequests = posts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _sentRequests = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('보낸 매칭 요청 불러오기 실패')));
    }
  }

  String formatDateRange(DateTime start, DateTime end) {
    final s = DateFormat('yyyy-MM-dd').format(start);
    final e = DateFormat('yyyy-MM-dd').format(end);
    return "$s ~ $e";
  }

  String formatPrice(int pay) {
    return NumberFormat("#,###").format(pay);
  }

  void _goToDetail(int postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailScreen(postId: postId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("보낸 매칭 요청")),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _sentRequests.isEmpty
              ? Center(child: Text("보낸 매칭 요청이 없습니다."))
              : ListView.builder(
                itemCount: _sentRequests.length,
                itemBuilder: (context, index) {
                  final post = _sentRequests[index];

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.send),
                      title: Text(
                        "[${post.type}] ${post.region}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "기간: ${formatDateRange(post.startedAt, post.endedAt)}",
                          ),
                          Text("요금: ${formatPrice(post.pay)}원"),
                          SizedBox(height: 4),
                          Text(
                            post.desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      onTap: () => _goToDetail(post.id),
                    ),
                  );
                },
              ),
    );
  }
}
