import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String classId;
  final DateTime dueDate;
  final String teacherId;
  final List<String> instructions;
  final DateTime createdAt;

  HomeworkModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.subject,
    required this.classId,
    required this.dueDate,
    required this.teacherId,
    required this.instructions,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'classId': classId,
      'dueDate': Timestamp.fromDate(dueDate),
      'teacherId': teacherId,
      'instructions': instructions,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory HomeworkModel.fromMap(String id, Map<String, dynamic> map) {
    return HomeworkModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      classId: map['classId'] ?? '',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      teacherId: map['teacherId'] ?? '',
      instructions: List<String>.from(map['instructions'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
