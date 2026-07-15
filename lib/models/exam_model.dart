import 'package:cloud_firestore/cloud_firestore.dart';

class ExamModel {
  final String id;
  final String name; // Unit Test, Mid Term, Final Exam
  final String subject;
  final String classId; // The class this exam is assigned to
  final DateTime date;
  final String startTime;
  final String endTime;
  final int totalMarks;

  ExamModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.classId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalMarks,
  });

  factory ExamModel.fromMap(String id, Map<String, dynamic> data) {
    return ExamModel(
      id: id,
      name: data['name'] ?? '',
      subject: data['subject'] ?? '',
      classId: data['classId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      totalMarks: data['totalMarks'] ?? 100,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subject': subject,
      'classId': classId,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'totalMarks': totalMarks,
    };
  }
}
