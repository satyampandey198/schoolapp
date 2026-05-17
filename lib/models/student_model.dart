class StudentModel {
  final String id;
  final String name;
  final String rollNumber;
  final String className;
  final String section;
  final String parentName;
  final String phone;
  final double attendancePercentage;
  bool isPresent;

  // Auto-generated login credentials
  final String loginUsername;
  final String loginPassword;

  StudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.section,
    this.parentName = '',
    this.phone = '',
    this.attendancePercentage = 0.0,
    this.isPresent = false,
    this.loginUsername = '',
    this.loginPassword = '',
  });

  /// Generates a username like "RVST12345"
  static String generateUsername(String name) {
    final ts = DateTime.now().millisecondsSinceEpoch % 100000;
    return 'RVST${ts.toString().padLeft(5, '0')}';
  }

  /// Generates a simple password
  static String generatePassword(String name) {
    return 'Student@123';
  }
}
