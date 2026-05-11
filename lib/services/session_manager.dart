import '../models/user_model.dart';

/// App-wide session singleton — holds the currently logged in user.
class SessionManager {
  SessionManager._internal();
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void login(UserModel user) => _currentUser = user;
  void logout() => _currentUser = null;
}
