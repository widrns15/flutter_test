import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pet_sitter_app/models/post.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostCreateScreen extends StatefulWidget {
  final Post? initialPost;
  const PostCreateScreen({this.initialPost, super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedType = '구인'; // or '구직'
  String _region = '서울';
  final _descController = TextEditingController();
  final _payController = TextEditingController();
  DateTime? _startedAt;
  DateTime? _endedAt;

  bool _isSubmitting = false;

  Future<void> _pickDateTime(bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startedAt = selected;
      } else {
        _endedAt = selected;
      }
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startedAt == null || _endedAt == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("시간을 모두 설정해주세요")));
      return;
    }

    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final response = await http.post(
      Uri.parse("http://192.168.0.232:22111/api/post"),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "type": _selectedType == '구인' ? 'hire' : 'work',
        "region": _region,
        "pay": int.tryParse(_payController.text) ?? 0,
        "startDate": _startedAt!.toIso8601String(),
        "endDate": _endedAt!.toIso8601String(),
        "description": _descController.text.trim(),
        "petIds": [], // 추후 반려동물 선택 UI 구현 시 연결 예정
      }),
    );

    setState(() => _isSubmitting = false);

    if (response.statusCode == 201 || response.statusCode == 200) {
      Navigator.pop(context, 'created');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("게시글이 등록되었습니다")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("등록 실패: ${response.body}")));
    }
  }

  String formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat("yyyy-MM-dd HH:mm").format(dt);
  }

  @override
  void dispose() {
    _descController.dispose();
    _payController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("게시글 등록")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                items:
                    ['구인', '구직']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: InputDecoration(labelText: "유형"),
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: "설명"),
                maxLines: 3,
                validator:
                    (val) => val == null || val.isEmpty ? "설명을 입력해주세요" : null,
              ),
              TextFormField(
                controller: _payController,
                decoration: InputDecoration(labelText: "요금 (원)"),
                keyboardType: TextInputType.number,
                validator:
                    (val) => val == null || val.isEmpty ? "요금을 입력해주세요" : null,
              ),
              DropdownButtonFormField<String>(
                value: _region,
                items:
                    ['서울', '부산', '대구']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                onChanged: (val) => setState(() => _region = val!),
                decoration: InputDecoration(labelText: "지역"),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDateTime(true),
                      child: Text(
                        _startedAt == null
                            ? "시작 시간 선택"
                            : "시작: ${formatDateTime(_startedAt)}",
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDateTime(false),
                      child: Text(
                        _endedAt == null
                            ? "종료 시간 선택"
                            : "종료: ${formatDateTime(_endedAt)}",
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                child: Text(_isSubmitting ? "등록 중..." : "등록"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
