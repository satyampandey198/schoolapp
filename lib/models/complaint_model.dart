class ComplaintModel {
  final String id;
  final String subject;
  final String description;
  final String status; // pending, resolved
  final String submitterId;
  final String submitterName;
  final String submitterRole; // student, teacher
  final String? adminReply;
  final DateTime createdAt;

  ComplaintModel({
    required this.id,
    required this.subject,
    required this.description,
    this.status = 'pending',
    required this.submitterId,
    required this.submitterName,
    required this.submitterRole,
    this.adminReply,
    required this.createdAt,
  });

  ComplaintModel copyWith({
    String? id,
    String? subject,
    String? description,
    String? status,
    String? submitterId,
    String? submitterName,
    String? submitterRole,
    String? adminReply,
    DateTime? createdAt,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      submitterId: submitterId ?? this.submitterId,
      submitterName: submitterName ?? this.submitterName,
      submitterRole: submitterRole ?? this.submitterRole,
      adminReply: adminReply ?? this.adminReply,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ComplaintModel.fromMap(String id, Map<String, dynamic> data) {
    return ComplaintModel(
      id: id,
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'pending',
      submitterId: data['submitterId'] ?? '',
      submitterName: data['submitterName'] ?? '',
      submitterRole: data['submitterRole'] ?? '',
      adminReply: data['adminReply'],
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'description': description,
      'status': status,
      'submitterId': submitterId,
      'submitterName': submitterName,
      'submitterRole': submitterRole,
      'adminReply': adminReply,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
