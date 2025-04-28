// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EveryPet';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get home => 'Home';

  @override
  String get myPage => 'My Page';

  @override
  String get languageSetting => 'Language Setting';

  @override
  String get matchingRequest => 'Matching Request';

  @override
  String get matchingReceived => 'Received Requests';

  @override
  String get matchingSent => 'Sent Requests';
}
