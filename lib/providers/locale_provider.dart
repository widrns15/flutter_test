import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale(); // Locale 로딩
  }

  // 로컬을 SharedPreferences에서 불러오기
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('locale') ?? 'ko'; // 기본값은 'ko' (한국어)
    _locale = Locale(localeCode);
    print("Loaded locale: $_locale"); // 확인용 로그 추가
    notifyListeners(); // 상태 변경 알리기
  }

  // 로컬 설정 후 SharedPreferences에 저장하고 알림
  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode); // SharedPreferences에 저장
    _locale = Locale(languageCode); // 상태 업데이트
    print("Updated locale: $_locale");
    notifyListeners(); // 상태 변경 알리기
  }
}
