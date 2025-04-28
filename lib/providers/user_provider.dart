import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  MyUser? _user;

  MyUser? get user => _user;
  bool get isLoggedIn => _user != null;

  void setUser(MyUser user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
