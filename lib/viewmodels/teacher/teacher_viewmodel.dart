import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/lecture_model.dart';
import '../../models/student_model.dart';
import '../../models/notification_model.dart';

class TeacherViewModel extends ChangeNotifier {
  List<LectureModel> _todayLectures = [];
  List<StudentModel> _classStudents = [];
  List<NotificationModel> _notifications = [];
  List<MarkModel> _marks = [];
  bool _attendanceSaved = false;
  DateTime _selectedAttendanceDate = DateTime.now();
  final Map<String, Map<String, bool>> _attendanceHistory = {};

  List<LectureModel> get todayLectures => _todayLectures;
  List<StudentModel> get classStudents => _classStudents;
  List<NotificationModel> get notifications => _notifications;
  List<MarkModel> get marks => _marks;
  List<String> get assignedSubjects => _marks.map((m) => m.subject).toSet().toList();
  bool get attendanceSaved => _attendanceSaved;
  DateTime get selectedAttendanceDate => _selectedAttendanceDate;
  int get presentCount => _classStudents.where((s) => s.isPresent).length;

  TeacherViewModel() {
    _initFirebaseListeners();
  }

  void _initFirebaseListeners() {
    final db = FirebaseFirestore.instance;

    // Listen to students
    db.collection('students').snapshots().listen((snapshot) {
      _classStudents = snapshot.docs.map((doc) {
        final data = doc.data();
        return StudentModel(
          id: doc.id,
          name: data['name'] ?? '',
          rollNumber: data['rollNumber'] ?? '',
          className: data['className'] ?? '',
          section: data['section'] ?? '',
        );
      }).toList();
      _loadAttendanceForDate(_selectedAttendanceDate);
      notifyListeners();
    });

    // Listen to notifications
    db.collection('notifications').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
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
    db.collection('marks').snapshots().listen((snapshot) {
      _marks = snapshot.docs.map((doc) {
        final data = doc.data();
        return MarkModel(
          studentId: data['studentId'] ?? '',
          studentName: data['studentName'] ?? '',
          rollNumber: data['rollNumber'] ?? '',
          marks: data['marks'] ?? 0,
          totalMarks: data['totalMarks'] ?? 100,
          subject: data['subject'] ?? '',
        );
      }).toList();
      notifyListeners();
    });
  }

  void _loadAttendanceForDate(DateTime date) {
    final dateKey = date.toString().split(' ')[0];
    if (!_attendanceHistory.containsKey(dateKey)) {
      FirebaseFirestore.instance.collection('attendance').doc(dateKey).get().then((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _attendanceHistory[dateKey] = data.map((key, value) => MapEntry(key, value as bool));
          for (var s in _classStudents) {
            s.isPresent = _attendanceHistory[dateKey]?[s.id] ?? false;
          }
          notifyListeners();
        }
      }).catchError((e) {
        print("Failed to load attendance: \$e");
        // Ignore error so app doesn't crash when offline
      });
    } else {
      for (var s in _classStudents) {
        s.isPresent = _attendanceHistory[dateKey]?[s.id] ?? false;
      }
    }
    _attendanceSaved = false;
  }

  void changeAttendanceDate(DateTime date) {
    _selectedAttendanceDate = date;
    _loadAttendanceForDate(date);
    notifyListeners();
  }

  void addStudent(StudentModel student) {
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
    
    await FirebaseFirestore.instance.collection('attendance').doc(dateKey).set(attendanceMap, SetOptions(merge: true));
    
    _attendanceHistory[dateKey] = attendanceMap;
    _attendanceSaved = true;
    notifyListeners();
  }

  void updateMark(String studentId, int newMark, {String? subject}) async {
    final markEntry = _marks.firstWhere((m) => m.studentId == studentId && (subject == null || m.subject == subject), orElse: () => MarkModel(studentId: studentId, studentName: '', rollNumber: '', marks: 0, totalMarks: 100, subject: ''));
    
    if (markEntry.studentName.isNotEmpty) {
      markEntry.marks = newMark;
      await FirebaseFirestore.instance.collection('marks').doc('${studentId}_${markEntry.subject}').set({
        'studentId': markEntry.studentId,
        'studentName': markEntry.studentName,
        'rollNumber': markEntry.rollNumber,
        'marks': newMark,
        'totalMarks': markEntry.totalMarks,
        'subject': markEntry.subject,
      }, SetOptions(merge: true));
      notifyListeners();
    }
  }
}
