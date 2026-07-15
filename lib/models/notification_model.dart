class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'success', 'alert'
  final DateTime createdAt;
  final String? targetRole;
  final String? targetType; // 'all_teachers', 'all_students', 'class', 'teacher', 'student'
  final String? targetId;   // specific ID for class, teacher, or student

  // Read receipts: maps studentId/userId -> name
  final Map<String, String> readBy;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'info',
    required this.createdAt,
    this.targetRole,
    this.targetType,
    this.targetId,
    Map<String, String>? readBy,
  }) : readBy = readBy ?? {};

  // Legacy compat
  bool get isRead => readBy.isNotEmpty;

  NotificationModel copyWith({
    bool? isRead,
    Map<String, String>? readBy,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      targetRole: targetRole,
      targetType: targetType,
      targetId: targetId,
      readBy: readBy ?? this.readBy,
    );
  }

  void markRead(String userId, String userName) {
    readBy[userId] = userName;
  }

  int get readCount => readBy.length;
}
