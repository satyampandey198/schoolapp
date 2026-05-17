class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'success', 'alert'
  final DateTime createdAt;
  final String? targetRole;

  // Read receipts: maps studentId/userId -> name
  final Map<String, String> readBy;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'info',
    required this.createdAt,
    this.targetRole,
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
      readBy: readBy ?? this.readBy,
    );
  }

  void markRead(String userId, String userName) {
    readBy[userId] = userName;
  }

  int get readCount => readBy.length;
}
