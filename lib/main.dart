import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_sitter_app/models/user.dart' as user_model;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'providers/locale_provider.dart';

import 'models/post.dart';
import 'models/user.dart';
import 'providers/user_provider.dart';

import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/login_screen.dart';
import 'screens/protected_route.dart';

// 게시판
import 'screens/home_screen.dart';
import 'screens/post_create_screen.dart';

// 마이페이지
import 'screens/profile_edit_page.dart';
import 'screens/matching_requests_screen.dart';
import 'screens/my_sent_requests_screen.dart';
import 'screens/pet_manage_screen.dart';
import 'screens/pet_register_screen.dart';
import 'package:pet_sitter_app/screens/language_setting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  final userProvider = UserProvider();
  await _loadUserFromToken(userProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const EveryPetApp(),
    ),
  );
}

Future<void> _loadUserFromToken(UserProvider userProvider) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  final expiresAt = prefs.getInt('accessTokenExpiresAt');

  if (token == null || expiresAt == null) return;

  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  if (now >= expiresAt) return;

  final res = await http.get(
    Uri.parse('http://192.168.0.232:22111/api/auth/me'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (res.statusCode == 200) {
    final userData = jsonDecode(res.body)['data'];
    userProvider.setUser(user_model.MyUser.fromJson(userData));
  }
}

class EveryPetApp extends StatelessWidget {
  const EveryPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    print("Current locale in MaterialApp: ${localeProvider.locale}");

    return MaterialApp(
      title: 'EveryPet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/',
      locale: localeProvider.locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      routes: {
        '/': (_) => LoginScreen(),
        '/login': (_) => LoginPage(),
        '/register': (_) => RegisterPage(),
        '/home': (_) => ProtectedRoute(child: HomeScreen()),
        '/profile-edit': (_) => ProtectedRoute(child: ProfileEditPage()),
        '/matching-requests':
            (_) => ProtectedRoute(child: MatchingRequestsScreen()),
        '/my-sent-requests':
            (_) => ProtectedRoute(child: MySentRequestsScreen()),
        '/pet-manage': (_) => ProtectedRoute(child: PetManageScreen()),
        '/pet-register': (_) => ProtectedRoute(child: PetRegisterScreen()),
        '/language-setting': (_) => LanguageSettingScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/post-create') {
          final post = settings.arguments as Post?;
          return MaterialPageRoute(
            builder:
                (_) =>
                    ProtectedRoute(child: PostCreateScreen(initialPost: post)),
          );
        }
        return null;
      },
    );
  }
}
