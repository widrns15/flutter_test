import 'package:flutter/material.dart';

class PetRegisterScreen extends StatefulWidget {
  @override
  State<PetRegisterScreen> createState() => _PetRegisterScreenState();
}

class _PetRegisterScreenState extends State<PetRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pet =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    _isEditing = pet != null;
    _nameController = TextEditingController(text: pet?['name'] ?? '');
    _typeController = TextEditingController(text: pet?['type'] ?? '');
    _noteController = TextEditingController(text: pet?['note'] ?? '');
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newPet = {
        'name': _nameController.text,
        'type': _typeController.text,
        'note': _noteController.text,
      };

      Navigator.pop(context, newPet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "반려동물 수정" : "반려동물 등록")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "이름"),
                validator: (value) => value!.isEmpty ? "이름을 입력해주세요" : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: "종류 (예: 강아지, 고양이)"),
                validator: (value) => value!.isEmpty ? "종류를 입력해주세요" : null,
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "특이사항 / 메모"),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? "수정 완료" : "등록"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
