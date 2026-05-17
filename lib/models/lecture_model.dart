class LectureModel {
  final String id;
  final String className;
  final String subject;
  final int totalStudents;
  final String startTime;
  final String endTime;
  final String room;
  final bool attendanceTaken;

  const LectureModel({
    required this.id,
    required this.className,
    required this.subject,
    required this.totalStudents,
    required this.startTime,
    required this.endTime,
    this.room = '',
    this.attendanceTaken = false,
  });
}

class MarkModel {
  final String studentId;
  final String studentName;
  final String rollNumber;
  int marks;
  final int totalMarks;
  final String subject;

  MarkModel({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.marks,
    required this.totalMarks,
    required this.subject,
  });

  double get percentage => (marks / totalMarks) * 100;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }
}

class TimetableEntry {
  final String day;
  final String subject;
  final String time;
  final String room;
  final String teacher;

  const TimetableEntry({
    required this.day,
    required this.subject,
    required this.time,
    required this.room,
    required this.teacher,
  });
}
