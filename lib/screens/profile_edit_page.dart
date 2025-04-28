import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: '홍길동');
  final _regionController = TextEditingController(text: '서울');
  final _emailController = TextEditingController(text: 'doglover@email.com');

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('프로필이 저장되었습니다.')));
      Navigator.pop(context, {
        'name': _nameController.text,
        'region': _regionController.text,
        'email': _emailController.text,
      });
    }
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("정말 탈퇴하시겠어요?"),
            content: Text("이 작업은 되돌릴 수 없습니다."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("취소"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context); // 닫기
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('회원탈퇴 처리가 완료되었습니다.')));
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: Text("탈퇴하기"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 정보 수정"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '이름'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "이름을 입력해주세요" : null,
              ),
              TextFormField(
                controller: _regionController,
                decoration: InputDecoration(labelText: '지역'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "지역을 입력해주세요" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "이메일을 입력해주세요" : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text("저장"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
              SizedBox(height: 16),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("로그아웃"),
                onTap: _logout,
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("회원탈퇴"),
                onTap: _deleteAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
