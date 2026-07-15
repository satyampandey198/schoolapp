class LectureScheduleModel {
  final String id;
  final String classId;
  final String className;
  final String teacherId;
  final String teacherName;
  final String subject;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status; // upcoming, completed, cancelled

  LectureScheduleModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = 'upcoming',
  });

  LectureScheduleModel copyWith({
    String? id,
    String? classId,
    String? className,
    String? teacherId,
    String? teacherName,
    String? subject,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? status,
  }) {
    return LectureScheduleModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  factory LectureScheduleModel.fromMap(String id, Map<String, dynamic> data) {
    return LectureScheduleModel(
      id: id,
      classId: data['classId'] ?? '',
      className: data['className'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      subject: data['subject'] ?? '',
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: data['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'className': className,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subject': subject,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
    };
  }
}
