/// Represents a logged-in user from Firebase Data Connect.
class UserModel {
  final String id;
  final String username;
  final String passwordHash;
  final String role;
  final String firstName;
  final String? lastName;
  final String? email;

  const UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.firstName,
    this.lastName,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
    );
  }

  String get fullName => '$firstName ${lastName ?? ''}'.trim();

  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'teacher':
        return 'Teacher';
      default:
        return 'Student';
    }
  }
}
