class AttendanceRecord {
  final String id;
  final String classId;
  final DateTime date;
  final Map<String, bool> records; // studentId -> isPresent
  final Map<String, bool>? originalRecords;
  final DateTime? editedTimestamp;
  final String? editedBy;

  AttendanceRecord({
    required this.id,
    required this.classId,
    required this.date,
    required this.records,
    this.originalRecords,
    this.editedTimestamp,
    this.editedBy,
  });

  bool get isEdited => editedTimestamp != null;

  AttendanceRecord copyWith({
    String? id,
    String? classId,
    DateTime? date,
    Map<String, bool>? records,
    Map<String, bool>? originalRecords,
    DateTime? editedTimestamp,
    String? editedBy,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      records: records ?? this.records,
      originalRecords: originalRecords ?? this.originalRecords,
      editedTimestamp: editedTimestamp ?? this.editedTimestamp,
      editedBy: editedBy ?? this.editedBy,
    );
  }

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceRecord(
      id: id,
      classId: data['classId'] ?? '',
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      records: Map<String, bool>.from(data['records'] ?? {}),
      originalRecords: data['originalRecords'] != null ? Map<String, bool>.from(data['originalRecords']) : null,
      editedTimestamp: data['editedTimestamp'] != null ? DateTime.parse(data['editedTimestamp']) : null,
      editedBy: data['editedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'date': date.toIso8601String(),
      'records': records,
      'originalRecords': originalRecords,
      'editedTimestamp': editedTimestamp?.toIso8601String(),
      'editedBy': editedBy,
    };
  }
}
