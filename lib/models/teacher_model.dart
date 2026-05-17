class TeacherModel {
  final String id;
  final String name;
  final String subject;
  final String assignedClass;
  final String experience;
  final String email;
  final String phone;
  final String qualification;
  final bool isActive;

  // Auto-generated login credentials
  final String loginUsername;
  final String loginPassword; // plain text for display, stored as hash in auth

  const TeacherModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.assignedClass,
    required this.experience,
    required this.email,
    required this.phone,
    this.qualification = '',
    this.isActive = true,
    this.loginUsername = '',
    this.loginPassword = '',
  });

  TeacherModel copyWith({
    String? name,
    String? subject,
    String? assignedClass,
    String? experience,
    String? email,
    String? phone,
    String? qualification,
    bool? isActive,
    String? loginUsername,
    String? loginPassword,
  }) {
    return TeacherModel(
      id: id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      assignedClass: assignedClass ?? this.assignedClass,
      experience: experience ?? this.experience,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      qualification: qualification ?? this.qualification,
      isActive: isActive ?? this.isActive,
      loginUsername: loginUsername ?? this.loginUsername,
      loginPassword: loginPassword ?? this.loginPassword,
    );
  }

  /// Generates a username like "RVTH12345"
  static String generateUsername(String name) {
    final ts = DateTime.now().millisecondsSinceEpoch % 100000;
    return 'RVTH${ts.toString().padLeft(5, '0')}';
  }

  /// Generates a simple password
  static String generatePassword(String name) {
    return 'Teacher@123';
  }
}
