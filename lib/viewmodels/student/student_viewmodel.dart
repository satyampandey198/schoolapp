import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../models/lecture_model.dart';
import '../../models/notification_model.dart';
import '../../models/homework_model.dart';
import '../../models/complaint_model.dart';
import '../../models/lecture_schedule_model.dart';
import '../../models/exam_model.dart';
import '../../models/mark_model.dart';

class StudentViewModel extends ChangeNotifier {
  double attendancePercentage = 87.5;
  int pendingHomework = 0;
  List<LectureScheduleModel> lectures = [];
  List<NotificationModel> notifications = [];
  List<MarkModel> results = [];
  List<HomeworkModel> homework = [];
  List<ComplaintModel> complaints = [];
  List<ExamModel> exams = [];
  
  String? _studentId;
  String? _classId;
  bool _isLoadingDashboard = true;

  // Stream Subscriptions to avoid memory leaks
  StreamSubscription? _notifSub;
  StreamSubscription? _homeworkSub;
  StreamSubscription? _marksSub;
  StreamSubscription? _lecturesSub;
  StreamSubscription? _complaintsSub;
  StreamSubscription? _examsSub;

  bool get isLoadingDashboard => _isLoadingDashboard;

  StudentViewModel();

  void updateUser(String? studentId) {
    if (_studentId == studentId) return;
    _cancelAllSubscriptions();
    _studentId = studentId;
    if (_studentId == null) {
      _classId = null;
      lectures = [];
      notifications = [];
      results = [];
      homework = [];
      complaints = [];
      exams = [];
      _isLoadingDashboard = true;
      notifyListeners();
    } else {
      _initFirebase();
    }
  }

  void _cancelAllSubscriptions() {
    _notifSub?.cancel();
    _homeworkSub?.cancel();
    _marksSub?.cancel();
    _lecturesSub?.cancel();
    _complaintsSub?.cancel();
    _examsSub?.cancel();
  }

  Future<void> _initFirebase() async {
    if (_studentId == null) return;
    
    _isLoadingDashboard = true;
    notifyListeners();

    try {
      // Fetch student's class information to get classId
      final doc = await FirebaseFirestore.instance.collection('students').doc(_studentId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final className = data['className'] ?? '';
        final section = data['section'] ?? '';
        _classId = 'c_${className.replaceAll(' ', '')}_$section';
      }
    } catch (e) {
      debugPrint("Error loading student class: $e");
    }

    _listenToNotifications();
    _listenToHomework();
    _listenToMarks();
    _listenToLectures();
    _listenToComplaints();
    _listenToExams();
  }

  void _listenToNotifications() {
    final alternateClassId = _classId != null 
        ? (_classId!.contains('_') ? _classId!.replaceAll('_', '-') : _classId!.replaceAll('-', '_'))
        : null;

    _notifSub = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .listen((snapshot) {
      final allNotifs = snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel(
          id: doc.id,
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          type: data['type'] ?? 'info',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          targetType: data['targetType'],
          targetId: data['targetId'],
          targetRole: data['targetRole'],
        );
      }).toList();

      // Filter notifications applicable to this student
      notifications = allNotifs.where((n) {
        if (n.targetRole == 'teacher') return false; // Not for students
        if (n.targetType == 'all_students') return true;
        if (n.targetType == 'class' && (n.targetId == _classId || n.targetId == alternateClassId)) return true;
        if (n.targetType == 'student' && n.targetId == _studentId) return true;
        // Legacy support or fallback
        if (n.targetType == null && (n.targetRole == null || n.targetRole == 'student')) return true;
        return false;
      }).toList();
      notifyListeners();
    });
  }

  void _listenToHomework() {
    final alternateClassId = _classId != null 
        ? (_classId!.contains('_') ? _classId!.replaceAll('_', '-') : _classId!.replaceAll('-', '_'))
        : null;

    _homeworkSub = FirebaseFirestore.instance
        .collection('homework')
        .snapshots()
        .listen((snapshot) {
      final allHw = snapshot.docs.map((doc) {
        return HomeworkModel.fromMap(doc.id, doc.data());
      }).toList();

      homework = allHw.where((hw) => hw.classId == _classId || hw.classId == alternateClassId).toList();
      pendingHomework = homework.length;
      notifyListeners();
    });
  }

  void _listenToMarks() {
    if (_studentId == null) return;
    _marksSub = FirebaseFirestore.instance
        .collection('marks')
        .where('studentId', isEqualTo: _studentId)
        .snapshots()
        .listen((snapshot) {
      results = snapshot.docs.map((doc) => MarkModel.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });
  }

  void _listenToLectures() {
    if (_classId == null) {
      _isLoadingDashboard = false;
      notifyListeners();
      return;
    }
    final alternateClassId = _classId!.contains('_') 
        ? _classId!.replaceAll('_', '-') 
        : _classId!.replaceAll('-', '_');

    _lecturesSub = FirebaseFirestore.instance
        .collection('lectures')
        .where('classId', whereIn: [_classId!, alternateClassId])
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      lectures = snapshot.docs.map((doc) => LectureScheduleModel.fromMap(doc.id, doc.data())).toList();
      _isLoadingDashboard = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error listening to lectures: $e");
      _isLoadingDashboard = false;
      notifyListeners();
    });
  }

  void _listenToComplaints() {
    if (_studentId == null) return;
    _complaintsSub = FirebaseFirestore.instance
        .collection('complaints')
        .where('submitterId', isEqualTo: _studentId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      complaints = snapshot.docs.map((doc) => ComplaintModel.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });
  }

  void _listenToExams() {
    if (_classId == null) return;
    final alternateClassId = _classId!.contains('_') 
        ? _classId!.replaceAll('_', '-') 
        : _classId!.replaceAll('-', '_');

    _examsSub = FirebaseFirestore.instance
        .collection('exams')
        .where('classId', whereIn: [_classId!, alternateClassId])
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      exams = snapshot.docs.map((doc) => ExamModel.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });
  }

  Future<void> submitComplaint(ComplaintModel complaint) async {
    await FirebaseFirestore.instance.collection('complaints').add(complaint.toMap());
  }

  @override
  void dispose() {
    _cancelAllSubscriptions();
    super.dispose();
  }
}
