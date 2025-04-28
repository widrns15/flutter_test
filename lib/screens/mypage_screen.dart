import 'package:flutter/material.dart';
import 'profile_edit_page.dart';

class MyPageScreen extends StatefulWidget {
  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String _name = '홍길동';
  String _email = 'doglover@email.com';
  String _region = '서울';

  void _navigateTo(BuildContext context, String route) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$route 화면으로 이동 (준비 중)')));
  }

  Future<void> _goToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileEditPage()),
    );

    if (result != null && mounted) {
      setState(() {
        _name = result['name'] ?? _name;
        _email = result['email'] ?? _email;
        _region = result['region'] ?? _region;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "마이페이지",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () async {
                      final changed = await Navigator.pushNamed(
                        context,
                        '/language-setting',
                      );
                      if (changed == true) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text(_name),
                      subtitle: Text("$_region | $_email"),
                      trailing: Icon(Icons.edit),
                      onTap: _goToEditProfile,
                    ),
                  ),
                  Divider(),

                  ListTile(
                    leading: Icon(Icons.send),
                    title: Text("보낸 매칭 요청"),
                    onTap:
                        () => Navigator.pushNamed(context, '/my-sent-requests'),
                  ),
                  ListTile(
                    leading: Icon(Icons.inbox),
                    title: Text("받은 매칭 요청"),
                    onTap:
                        () =>
                            Navigator.pushNamed(context, '/matching-requests'),
                  ),
                  Divider(),

                  ListTile(
                    leading: Icon(Icons.pets),
                    title: Text("내 반려동물 관리"),
                    onTap: () => Navigator.pushNamed(context, '/pet-manage'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
