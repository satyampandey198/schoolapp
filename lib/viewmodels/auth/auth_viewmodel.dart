import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get role => _currentUser?.role ?? '';

  // We keep _mockUsers for fallback/UI previews if Firebase isn't set up yet,
  // but we will primarily use Firebase.
  static List<UserModel> _mockUsers = [];

  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId');
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          _currentUser = UserModel(
            id: doc.id,
            username: doc['username'] ?? '',
            passwordHash: '', 
            role: doc['role'] ?? '',
            firstName: doc['firstName'] ?? '',
            lastName: doc['lastName'],
            email: doc['email'],
          );
          notifyListeners();
        }
      } catch (e) {
        print('Session load error: $e');
      }
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = FirebaseFirestore.instance;
      // 1. Find email by username
      final userQuery = await db.collection('users').where('username', isEqualTo: username).limit(1).get();
      if (userQuery.docs.isEmpty) {
        _errorMessage = 'Invalid username or password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final doc = userQuery.docs.first;
      final email = doc['email'] as String;
      
      // 2. Pure Firestore verification (Bypass FirebaseAuth entirely)
      if (doc['loginPassword'] != password) {
        _errorMessage = 'Invalid username or password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // 3. Load user model
      _currentUser = UserModel(
        id: doc.id,
        username: doc['username'] ?? '',
        passwordHash: '', 
        role: doc['role'] ?? '',
        firstName: doc['firstName'] ?? '',
        lastName: doc['lastName'],
        email: doc['email'],
      );

      // Save to SharedPreferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', doc.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() async {
    // await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void addMockUser(UserModel user) {
    _mockUsers.add(user);
  }

  void updatePassword(String userId, String newPassword) async {
    try {
      // If the currently logged in user is changing their own password
      // if (_currentUser?.id == userId) {
      //   await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      // }
      // Note: Changing other users' passwords via client SDK requires re-authentication 
      // or using a cloud function (Admin SDK). For this demo, we'll update the 'users' doc.
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'loginPassword': newPassword,
      });
      
      ScaffoldMessengerState? state; // Could be passed, omitting for logic purity
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
