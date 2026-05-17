class ClassModel {
  final String id;
  String name;
  String section;
  int totalStudents;
  final String classTeacherId;   // Main class teacher
  final String classTeacherName; // Main class teacher name
  final List<SubjectTeacherEntry> lectureTeachers; // Subject-wise teachers
  final List<String> subjects;

  ClassModel({
    required this.id,
    required this.name,
    required this.section,
    this.totalStudents = 0,
    this.classTeacherId = '',
    this.classTeacherName = '',
    this.lectureTeachers = const [],
    this.subjects = const [],
  });

  String get displayName => '$name - $section';

  // Legacy compat
  String get teacherName => classTeacherName;
  String get teacherId => classTeacherId;

  ClassModel copyWith({
    String? name,
    String? section,
    int? totalStudents,
    String? classTeacherId,
    String? classTeacherName,
    List<SubjectTeacherEntry>? lectureTeachers,
    List<String>? subjects,
  }) {
    return ClassModel(
      id: id,
      name: name ?? this.name,
      section: section ?? this.section,
      totalStudents: totalStudents ?? this.totalStudents,
      classTeacherId: classTeacherId ?? this.classTeacherId,
      classTeacherName: classTeacherName ?? this.classTeacherName,
      lectureTeachers: lectureTeachers ?? this.lectureTeachers,
      subjects: subjects ?? this.subjects,
    );
  }
}

class SubjectTeacherEntry {
  final String subject;
  final String teacherId;
  final String teacherName;

  const SubjectTeacherEntry({
    required this.subject,
    required this.teacherId,
    required this.teacherName,
  });
}
