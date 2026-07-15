class MarkModel {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNumber;
  int marks;
  final int totalMarks;
  final String subject;
  final String examId;
  final String examType;

  MarkModel({
    this.id = '',
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.marks,
    required this.totalMarks,
    required this.subject,
    required this.examId,
    required this.examType,
  });

  double get percentage => totalMarks > 0 ? (marks / totalMarks) * 100 : 0;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  factory MarkModel.fromMap(String id, Map<String, dynamic> data) {
    return MarkModel(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      marks: data['marks'] ?? 0,
      totalMarks: data['totalMarks'] ?? 100,
      subject: data['subject'] ?? '',
      examId: data['examId'] ?? '',
      examType: data['examType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'marks': marks,
      'totalMarks': totalMarks,
      'subject': subject,
      'examId': examId,
      'examType': examType,
    };
  }
}
