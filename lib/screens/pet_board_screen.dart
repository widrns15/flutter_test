import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/post.dart';
import 'post_create_screen.dart';
import 'post_detail_screen.dart';

class PetBoardScreen extends StatefulWidget {
  const PetBoardScreen({super.key});

  @override
  State<PetBoardScreen> createState() => _PetBoardScreenState();
}

class _PetBoardScreenState extends State<PetBoardScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;

  String _selectedType = '전체';
  String _selectedRegion = '전체';

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final queryParams = {
      'page': '1',
      'limit': '10',
      'status': 'open',
      'type':
          _selectedType == '전체'
              ? ''
              : (_selectedType == '구직' ? 'work' : 'hire'),
      'region': _selectedRegion == '전체' ? '' : _selectedRegion,
    };

    final queryString = queryParams.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final uri = Uri.parse('http://192.168.0.232:22111/api/post?$queryString');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final dataList = body['data']?['data'];

      if (dataList is List) {
        final posts = dataList.map((p) => Post.fromJson(p)).toList();
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _posts = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('게시글 데이터가 유효하지 않습니다.')));
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('게시글 불러오기 실패')));
    }
  }

  String formatDateRange(DateTime start, DateTime end) {
    final s = DateFormat('yyyy-MM-dd').format(start);
    final e = DateFormat('yyyy-MM-dd').format(end);
    return "$s ~ $e";
  }

  String formatPrice(int price) {
    return NumberFormat("#,###").format(price);
  }

  Future<void> _goToPostCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostCreateScreen()),
    );
    if (result == 'created') {
      _fetchPosts();
    }
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
      appBar: AppBar(
        title: Text("펫 게시판"),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchPosts),
          IconButton(icon: Icon(Icons.add), onPressed: _goToPostCreate),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _selectedType,
                  items:
                      ['전체', '구인', '구직']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() => _selectedType = val!);
                    _fetchPosts();
                  },
                ),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedRegion,
                  items:
                      ['전체', '서울', '부산', '대구']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() => _selectedRegion = val!);
                    _fetchPosts();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _posts.isEmpty
                    ? Center(child: Text("게시글이 없습니다."))
                    : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text("[${post.type}] ${post.desc}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("지역: ${post.region}"),
                                Text("요금: ${formatPrice(post.pay)}원"),
                                Text(
                                  "기간: ${formatDateRange(post.startedAt, post.endedAt)}",
                                ),
                              ],
                            ),
                            onTap: () => _goToDetail(post.id),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
