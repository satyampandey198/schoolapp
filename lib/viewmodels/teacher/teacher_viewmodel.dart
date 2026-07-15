import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/lecture_model.dart';
import '../../models/student_model.dart';
import '../../models/notification_model.dart';
import '../../models/homework_model.dart';
import '../../models/complaint_model.dart';
import '../../models/attendance_model.dart';
import '../../models/mark_model.dart';
import '../../models/exam_model.dart';
import 'dart:async';

class TeacherViewModel extends ChangeNotifier {
  List<LectureModel> _todayLectures = [];
  List<StudentModel> _classStudents = [];
  List<NotificationModel> _notifications = [];
  List<MarkModel> _marks = [];
  List<HomeworkModel> _homeworkList = [];
  List<ComplaintModel> _complaints = [];
  List<ExamModel> _exams = [];
  AttendanceRecord? _currentAttendanceRecord;
  bool _attendanceSaved = false;
  DateTime _selectedAttendanceDate = DateTime.now();
  final Map<String, Map<String, bool>> _attendanceHistory = {};
  bool _isLoadingDashboard = true;

  List<LectureModel> get todayLectures => _todayLectures;
  List<StudentModel> get classStudents => _classStudents;
  List<NotificationModel> get notifications => _notifications;
  List<MarkModel> get marks => _marks;
  List<HomeworkModel> get homeworkList => _homeworkList;
  List<ComplaintModel> get complaints => _complaints;
  List<ExamModel> get exams => _exams;
  List<String> get assignedSubjects => _marks.map((m) => m.subject).toSet().toList();
  bool get attendanceSaved => _attendanceSaved;
  DateTime get selectedAttendanceDate => _selectedAttendanceDate;
  AttendanceRecord? get currentAttendanceRecord => _currentAttendanceRecord;
  int get presentCount => _classStudents.where((s) => s.isPresent).length;
  bool get isLoadingDashboard => _isLoadingDashboard;

  String? _teacherId;
  TeacherModel? _teacherModel;
  List<StudentModel> _allStudents = [];

  StreamSubscription? _teacherProfileSub;
  StreamSubscription? _complaintsSub;
  StreamSubscription? _studentsSub;
  StreamSubscription? _notificationsSub;
  StreamSubscription? _marksSub;
  StreamSubscription? _homeworkSub;
  StreamSubscription? _examsSub;

  String? get teacherId => _teacherId;
  TeacherModel? get teacherModel => _teacherModel;

  TeacherViewModel() {
    _initFirebaseListeners();
  }

  void updateUser(String? userId) {
    if (_teacherId == userId) return;
    _teacherId = userId;
    
    _teacherProfileSub?.cancel();
    _complaintsSub?.cancel();
    _teacherModel = null;
    _complaints = [];
    
    if (_teacherId != null) {
      _listenToTeacherProfile();
      _listenToComplaints();
    } else {
      _filterClassStudents();
      notifyListeners();
    }
  }

  void _listenToTeacherProfile() {
    _teacherProfileSub = FirebaseFirestore.instance
        .collection('teachers')
        .doc(_teacherId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        _teacherModel = TeacherModel(
          id: doc.id,
          name: data['name'] ?? '',
          subject: data['subject'] ?? '',
          assignedClass: data['assignedClass'] ?? '',
          experience: data['experience'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          qualification: data['qualification'] ?? '',
          isActive: data['isActive'] ?? true,
          loginUsername: data['loginUsername'] ?? '',
          loginPassword: data['loginPassword'] ?? '',
        );
        _filterClassStudents();
      }
    });
  }

  void _filterClassStudents() {
    if (_teacherModel == null || _teacherModel!.assignedClass.isEmpty) {
      _classStudents = List.from(_allStudents);
    } else {
      final tClass = _teacherModel!.assignedClass.replaceAll(' ', '').replaceAll('-', '_').toLowerCase();
      _classStudents = _allStudents.where((s) {
        final sClass = '${s.className}_${s.section}'.replaceAll(' ', '').toLowerCase();
        final sClassHyphen = '${s.className}-${s.section}'.replaceAll(' ', '').toLowerCase();
        return sClass == tClass || sClassHyphen == tClass || s.className.toLowerCase() == _teacherModel!.assignedClass.toLowerCase();
      }).toList();
    }
    _loadAttendanceForDate(_selectedAttendanceDate);
    _isLoadingDashboard = false;
    notifyListeners();
  }

  void _initFirebaseListeners() {
    final db = FirebaseFirestore.instance;

    // Listen to students
    _studentsSub = db.collection('students').snapshots().listen((snapshot) {
      _allStudents = snapshot.docs.map((doc) {
        final data = doc.data();
        return StudentModel(
          id: doc.id,
          name: data['name'] ?? '',
          rollNumber: data['rollNumber'] ?? '',
          className: data['className'] ?? '',
          section: data['section'] ?? '',
        );
      }).toList();
      _filterClassStudents();
    });

    // Listen to notifications
    _notificationsSub = db.collection('notifications').orderBy('createdAt', descending: true).limit(20).snapshots().listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel(
          id: doc.id,
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          type: data['type'] ?? 'info',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      notifyListeners();
    });

    // Listen to marks
    _marksSub = db.collection('marks').snapshots().listen((snapshot) {
      _marks = snapshot.docs.map((doc) => MarkModel.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });

    // Listen to homework
    _homeworkSub = db.collection('homework').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      _homeworkList = snapshot.docs.map((doc) => HomeworkModel.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });

    // Listen to exams
    _examsSub = db.collection('exams').orderBy('date').snapshots().listen((snapshot) {
      _exams = snapshot.docs.map((doc) => ExamModel.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });
  }

  void _listenToComplaints() {
    if (_teacherId == null) return;
    _complaintsSub = FirebaseFirestore.instance
        .collection('complaints')
        .where('submitterId', isEqualTo: _teacherId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      _complaints = snapshot.docs.map((doc) => ComplaintModel.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });
  }

  Future<void> submitComplaint(ComplaintModel complaint) async {
    await FirebaseFirestore.instance.collection('complaints').add(complaint.toMap());
  }

  void _loadAttendanceForDate(DateTime date) {
    final dateKey = date.toString().split(' ')[0];
    FirebaseFirestore.instance.collection('attendance_records').doc(dateKey).get().then((doc) {
      if (doc.exists) {
        _currentAttendanceRecord = AttendanceRecord.fromMap(doc.id, doc.data()!);
        _attendanceHistory[dateKey] = _currentAttendanceRecord!.records;
      } else {
        _currentAttendanceRecord = null;
      }
      for (var s in _classStudents) {
        s.isPresent = _attendanceHistory[dateKey]?[s.id] ?? false;
      }
      notifyListeners();
    }).catchError((e) {
      print("Failed to load attendance: $e");
    });
    _attendanceSaved = false;
  }

  void changeAttendanceDate(DateTime date) {
    _selectedAttendanceDate = date;
    _loadAttendanceForDate(date);
    notifyListeners();
  }

  Future<void> addStudent(StudentModel student) async {
    // Actually handled by AdminViewModel / Firebase triggers
  }

  void toggleAttendance(String id) {
    final idx = _classStudents.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _classStudents[idx].isPresent = !_classStudents[idx].isPresent;
      _attendanceSaved = false;
      notifyListeners();
    }
  }

  Future<void> saveAttendance() async {
    final dateKey = _selectedAttendanceDate.toString().split(' ')[0];
    final attendanceMap = {for (var s in _classStudents) s.id: s.isPresent};
    
    // Check if editing
    final isEditing = _currentAttendanceRecord != null;
    final originalRecords = isEditing ? _currentAttendanceRecord!.originalRecords ?? _currentAttendanceRecord!.records : null;
    
    final record = AttendanceRecord(
      id: dateKey,
      classId: 'all', // Simplified, could use real classId
      date: _selectedAttendanceDate,
      records: attendanceMap,
      originalRecords: isEditing ? originalRecords : attendanceMap,
      editedTimestamp: isEditing ? DateTime.now() : null,
      editedBy: isEditing ? _teacherId : null,
    );

    await FirebaseFirestore.instance.collection('attendance_records').doc(dateKey).set(record.toMap());
    
    _attendanceHistory[dateKey] = attendanceMap;
    _currentAttendanceRecord = record;
    _attendanceSaved = true;
    notifyListeners();
  }

  Future<void> updateMark(
    String studentId, 
    int newMark, 
    {
      String? subject, 
      required String examId, 
      String? examType,
      required String studentName,
      required String rollNumber,
    }
  ) async {
    // We fetch the exam to get total marks, fallback to 100 if not found
    final exam = _exams.firstWhere((e) => e.id == examId, orElse: () => ExamModel(id: examId, name: examType ?? 'Unit Test', subject: subject ?? '', classId: '', date: DateTime.now(), startTime: '', endTime: '', totalMarks: 100));

    final markEntry = _marks.firstWhere(
      (m) => m.studentId == studentId && m.examId == examId, 
      orElse: () => MarkModel(
        studentId: studentId, 
        studentName: studentName, 
        rollNumber: rollNumber, 
        marks: 0, 
        totalMarks: exam.totalMarks, 
        subject: exam.subject, 
        examId: exam.id, 
        examType: exam.name
      )
    );
    
    if (newMark > markEntry.totalMarks) {
      throw Exception("Marks cannot exceed total marks (${markEntry.totalMarks})");
    }
    
    markEntry.marks = newMark;
    await FirebaseFirestore.instance.collection('marks').doc('${studentId}_$examId').set(markEntry.toMap(), SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> sendNotification(String title, String message, String type, {String? targetType, String? targetId, String? imageUrl}) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'targetType': targetType,
      'targetId': targetId,
      'imageUrl': imageUrl,
      'readBy': {},
    });
  }

  Future<void> addHomework(HomeworkModel hw) async {
    await FirebaseFirestore.instance.collection('homework').add(hw.toMap());
  }

  // ──── TIMETABLE ───────────────────────────────────────────────────────
  Future<void> saveTimetableEntry(String classId, TimetableEntry entry) async {
    // Generate a unique ID if it doesn't exist. Usually we'd map this, 
    // but a simple composite key works well.
    final docId = '${classId}_${entry.day}_${entry.time.replaceAll(RegExp(r'\W'), '')}';
    
    await FirebaseFirestore.instance.collection('timetable').doc(docId).set({
      'classId': classId,
      'day': entry.day,
      'subject': entry.subject,
      'time': entry.time,
      'room': entry.room,
      'teacher': entry.teacher,
    }, SetOptions(merge: true));
  }

  Future<void> removeTimetableEntry(String classId, String day, String time) async {
    final docId = '${classId}_${day}_${time.replaceAll(RegExp(r'\W'), '')}';
    await FirebaseFirestore.instance.collection('timetable').doc(docId).delete();
  }
}
