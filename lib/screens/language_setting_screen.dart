import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:pet_sitter_app/generated/l10n.dart'; // 다국어 처리

// LocaleProvider를 import
import '../providers/locale_provider.dart';

class LanguageSettingScreen extends StatefulWidget {
  @override
  State<LanguageSettingScreen> createState() => _LanguageSettingScreenState();
}

class _LanguageSettingScreenState extends State<LanguageSettingScreen> {
  String? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  // SharedPreferences에서 저장된 locale 불러오기
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLocale = prefs.getString('locale') ?? 'ko'; // 기본 한국어
    });
  }

  // Locale 변경 후 SharedPreferences에 저장
  Future<void> _changeLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);

    // 상태 변경 후 언어 변경
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    localeProvider.setLocale(locale); // 여기서 locale을 set

    setState(() {
      _selectedLocale = locale;
    });

    Navigator.pop(context, true); // 언어 변경 후 이전 화면으로 돌아감
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).languageSetting)),
      body: ListView(
        children: [
          // 한국어 선택
          RadioListTile<String>(
            title: Text('한국어'),
            value: 'ko',
            groupValue: _selectedLocale,
            onChanged: (val) => _changeLocale(val!),
          ),
          // 영어 선택
          RadioListTile<String>(
            title: Text('English'),
            value: 'en',
            groupValue: _selectedLocale,
            onChanged: (val) => _changeLocale(val!),
          ),
        ],
      ),
    );
  }
}
