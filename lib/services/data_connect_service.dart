import '../models/user_model.dart';

/// Stub service — UI-only mode. Data served from AuthViewModel mock data.
class DataConnectService {
  static Future<UserModel?> getUserByUsername(String username) async {
    // Intentionally empty — login handled by AuthViewModel
    return null;
  }
}

class HttpException implements Exception {
  final String message;
  const HttpException(this.message);
  @override
  String toString() => message;
}
