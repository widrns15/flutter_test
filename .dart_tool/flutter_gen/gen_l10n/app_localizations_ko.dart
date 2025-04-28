// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class SKo extends S {
  SKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'EveryPet';

  @override
  String get login => '로그인';

  @override
  String get register => '회원가입';

  @override
  String get home => '홈';

  @override
  String get myPage => '마이페이지';

  @override
  String get languageSetting => '언어 설정';

  @override
  String get matchingRequest => '매칭 요청';

  @override
  String get matchingReceived => '받은 매칭 요청';

  @override
  String get matchingSent => '보낸 매칭 요청';
}
