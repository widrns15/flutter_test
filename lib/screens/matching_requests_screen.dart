import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/matching_request.dart';
import 'post_detail_screen.dart';

class MatchingRequestsScreen extends StatefulWidget {
  @override
  State<MatchingRequestsScreen> createState() => _MatchingRequestsScreenState();
}

class _MatchingRequestsScreenState extends State<MatchingRequestsScreen> {
  List<MatchingRequest> requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatchingRequests();
  }

  Future<void> _fetchMatchingRequests() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.0.232:22111/api/mypage/matching/received'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final dataList = body['data'];

      if (dataList != null && dataList is List) {
        final items = dataList.map((p) => MatchingRequest.fromJson(p)).toList();
        setState(() {
          requests = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          requests = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('받은 매칭 요청 불러오기 실패')));
    }
  }

  Future<void> _acceptRequest(int matchingRequestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.patch(
      Uri.parse(
        'http://192.168.0.232:22111/api/matching/accept/$matchingRequestId',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        requests.removeWhere((r) => r.id == matchingRequestId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('매칭 요청을 수락했습니다.')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('수락 실패')));
    }
  }

  Future<void> _rejectRequest(int matchingRequestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final response = await http.patch(
      Uri.parse(
        'http://192.168.0.232:22111/api/matching/reject/$matchingRequestId',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        requests.removeWhere((r) => r.id == matchingRequestId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('매칭 요청을 거절했습니다.')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('거절 실패')));
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
      appBar: AppBar(title: Text("받은 매칭 요청")),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : requests.isEmpty
              ? Center(child: Text("받은 매칭 요청이 없습니다."))
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final post = request.post;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.pets),
                      title: Text(
                        "[${post?.type ?? '-'}] ${post?.region ?? '-'}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "기간: ${post != null ? formatDateRange(post.startedAt, post.endedAt) : '-'}",
                          ),
                          Text(
                            "요금: ${post != null ? formatPrice(post.pay) : '-'}원",
                          ),
                          SizedBox(height: 4),
                          Text(
                            post?.desc ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _acceptRequest(request.id),
                            child: Text("수락"),
                          ),
                          TextButton(
                            onPressed: () => _rejectRequest(request.id),
                            child: Text(
                              "거절",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _goToDetail(post?.id ?? 0),
                    ),
                  );
                },
              ),
    );
  }
}
