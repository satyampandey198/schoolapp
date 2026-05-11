import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

/// Service that queries Firebase Data Connect via REST API.
/// Falls back to local credential store when the connector is not yet deployed.
class DataConnectService {
  static const _projectId = 'schooladminproject-66cb7';
  static const _location = 'us-central1';
  static const _serviceId = 'schoolapp';
  static const _connectorId = 'default';
  static const _apiKey = 'AIzaSyD4X_U4zX8QFmZoB-PZOFzpQhwtu12fBNg';

  // ── Local credential store (mirrors the Data Connect DB exactly) ───────────
  // passwordHash format = "hashed_<password>" — user types the part after "hashed_"
  static const _localUsers = [
    {
      'id': '83ce20e24da542b882f63e0bdb61c8e6',
      'username': 'admin01',
      'passwordHash': 'hashed_admin_123',
      'role': 'admin',
      'firstName': 'Satyam',
      'lastName': 'Pandey',
      'email': 'admin@school.com',
    },
    {
      'id': '73cc3a10a4ea45babe9f44d41a2e7ab4',
      'username': 'teacher01',
      'passwordHash': 'hashed_teacher_123',
      'role': 'teacher',
      'firstName': 'Anita',
      'lastName': 'Sharma',
      'email': 'teacher@school.com',
    },
    {
      'id': '116c3bc930f3465aa21b5a9cfac09b16',
      'username': 'student01',
      'passwordHash': 'hashed_student_123',
      'role': 'student',
      'firstName': 'Rahul',
      'lastName': 'Verma',
      'email': 'student1@school.com',
    },
    {
      'id': '16a3ed85ffdc4108a8e2245532a58f64',
      'username': 'student02',
      'passwordHash': 'hashed_student_456',
      'role': 'student',
      'firstName': 'Priya',
      'lastName': 'Singh',
      'email': 'student2@school.com',
    },
  ];

  static Uri get _queryEndpoint => Uri.parse(
        'https://firebasedataconnect.googleapis.com/v1beta'
        '/projects/$_projectId'
        '/locations/$_location'
        '/services/$_serviceId'
        '/connectors/$_connectorId'
        ':executeQuery?key=$_apiKey',
      );

  // ── PUBLIC API ─────────────────────────────────────────────────────────────

  /// Fetches a user by [username].
  /// 1. Tries Firebase Data Connect REST API first.
  /// 2. Falls back to local store if the API is unavailable / not deployed.
  static Future<UserModel?> getUserByUsername(String username) async {
    // ① Try live Data Connect endpoint
    try {
      final user = await _fetchFromDataConnect(username);
      debugPrint('[DataConnect] Live fetch succeeded for "$username"');
      return user;
    } catch (e) {
      debugPrint('[DataConnect] Live fetch failed: $e — using local fallback.');
    }

    // ② Local fallback
    return _fetchFromLocal(username);
  }

  // ── PRIVATE HELPERS ────────────────────────────────────────────────────────

  static Future<UserModel?> _fetchFromDataConnect(String username) async {
    final response = await http
        .post(
          _queryEndpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'operationName': 'GetUserByUsername',
            'variables': {'username': username},
          }),
        )
        .timeout(const Duration(seconds: 8));

    debugPrint('[DataConnect] HTTP ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final users = json['data']?['users'] as List?;
      if (users != null && users.isNotEmpty) {
        return UserModel.fromJson(users.first as Map<String, dynamic>);
      }
      return null; // username not found
    }

    // Any non-200 response throws so the caller can fall back
    throw HttpException('HTTP ${response.statusCode}: ${response.body}');
  }

  static UserModel? _fetchFromLocal(String username) {
    final match = _localUsers.cast<Map<String, dynamic>>().where(
          (u) => u['username'] == username,
        );
    if (match.isEmpty) return null;
    return UserModel.fromJson(match.first);
  }
}

class HttpException implements Exception {
  final String message;
  const HttpException(this.message);
  @override
  String toString() => message;
}
