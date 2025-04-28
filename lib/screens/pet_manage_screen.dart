import 'package:flutter/material.dart';

class PetManageScreen extends StatefulWidget {
  @override
  State<PetManageScreen> createState() => _PetManageScreenState();
}

class _PetManageScreenState extends State<PetManageScreen> {
  List<Map<String, String>> pets = [
    {'name': '콩이', 'type': '강아지', 'note': '산책 좋아해요'},
    {'name': '야옹이', 'type': '고양이', 'note': '낯가림 있음'},
  ];

  void _editPet(int index) async {
    final pet = pets[index];
    final edited = await Navigator.pushNamed(
      context,
      '/pet-register',
      arguments: pet,
    );

    if (edited is Map<String, String>) {
      setState(() {
        pets[index] = edited;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("반려동물 정보가 수정되었습니다.")));
    }
  }

  void _deletePet(int index) {
    final petName = pets[index]['name'];
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("삭제 확인"),
            content: Text("$petName 을(를) 정말 삭제하시겠습니까?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("취소"),
              ),
              TextButton(
                onPressed: () {
                  setState(() => pets.removeAt(index));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$petName 이(가) 삭제되었습니다.")),
                  );
                },
                child: Text("삭제", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 반려동물"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: "반려동물 등록",
            onPressed: () async {
              final newPet = await Navigator.pushNamed(
                context,
                '/pet-register',
              );
              if (newPet is Map<String, String>) {
                setState(() => pets.add(newPet));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("반려동물이 등록되었습니다.")));
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.pets),
              title: Text(pet['name'] ?? ''),
              subtitle: Text('${pet['type']} - ${pet['note']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.teal),
                    onPressed: () => _editPet(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePet(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
