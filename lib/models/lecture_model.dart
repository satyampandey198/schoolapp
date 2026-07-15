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
