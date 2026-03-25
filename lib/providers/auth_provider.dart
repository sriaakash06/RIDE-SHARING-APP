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

  // Returns null on success, error message string on failure
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    String? error = await _authService.signIn(email, password);

    if (error == null) {
      // Success — now try to fetch user data
      try {
        if (!isFirebaseInitialized) {
          _userModel = await _authService.getUserData('mock_uid');
        } else {
          // Force fetch data immediately to catch Firestore rules issues before returning success
          _userModel = await _authService.getUserData(_authService.user.first.toString());
        }
      } catch (e) {
        // If Firestore blocks the read (e.g. permission rules), we logout and return the error
        await _authService.signOut();
        _userModel = null;
        
        // This regex/check catches standard Firestore permission denied errors
        if (e.toString().contains('permission-denied') || e.toString().contains('PERMISSION_DENIED')) {
          error = "Database Error: Please ensure Firestore Database is created in Test Mode.";
        } else {
          error = e.toString();
        }
      }
    }

    _isLoading = false;
    notifyListeners();

    return error; // null = success, string = error message
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
