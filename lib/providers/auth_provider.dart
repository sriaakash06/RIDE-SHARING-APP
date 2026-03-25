import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../main.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  AuthProvider() {
    if (isFirebaseInitialized) {
      _authService.user.listen((User? user) async {
        if (user != null) {
          _userModel = await _authService.getUserData(user.uid);
        } else {
          _userModel = null;
        }
        notifyListeners();
      });
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    var result = await _authService.signIn(email, password);
    
    if (!isFirebaseInitialized && result != null) {
      _userModel = await _authService.getUserData('mock_uid');
    }
    
    _isLoading = false;
    notifyListeners();
    
    return result != null;
  }

  // Returns null on success, error message string on failure
  Future<String?> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    String? error = await _authService.signUp(email, password, name);

    if (error == null) {
      // Success — for mock mode set user manually
      if (!isFirebaseInitialized) {
        _userModel = UserModel(uid: 'mock_uid', email: email, name: name);
      }
      // For real Firebase, the auth stream will auto-update _userModel
    }

    _isLoading = false;
    notifyListeners();

    return error; // null = success, string = error message
  }

  Future<void> logout() async {
    await _authService.signOut();
    if (!isFirebaseInitialized) {
      _userModel = null;
      notifyListeners();
    }
  }
}
