import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/teacher_model.dart';
import '../../models/student_model.dart';
import '../../models/class_model.dart';
import '../../models/notification_model.dart';

class AdminViewModel extends ChangeNotifier {
  List<TeacherModel> _teachers = [];
  List<StudentModel> _students = [];
  List<ClassModel> _classes = [];
  List<NotificationModel> _notifications = [];
  List<String> _globalSubjects = [];
  String _searchQuery = '';
  bool _isLoading = false;



  List<TeacherModel> get teachers => _teachers
      .where((t) =>
          _searchQuery.isEmpty ||
          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.subject.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();
  List<StudentModel> get students => _students;
  List<ClassModel> get classes => _classes;
  List<NotificationModel> get notifications => _notifications;
  List<String> get globalSubjects => _globalSubjects;

  bool get isLoading => _isLoading;
  int get totalTeachers => _teachers.length;
  int get totalStudents => _students.length;
  int get totalClasses => _classes.length;

  AdminViewModel() {
    _initFirebaseListeners();
  }

  void _initFirebaseListeners() {
    final db = FirebaseFirestore.instance;

    // Listen to Teachers
    db.collection('teachers').snapshots().listen((snapshot) {
      _teachers = snapshot.docs.map((doc) {
        final data = doc.data();
        return TeacherModel(
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
      }).toList();
      notifyListeners();
    });

    // Listen to Students
    db.collection('students').snapshots().listen((snapshot) {
      _students = snapshot.docs.map((doc) {
        final data = doc.data();
        return StudentModel(
          id: doc.id,
          name: data['name'] ?? '',
          rollNumber: data['rollNumber'] ?? '',
          className: data['className'] ?? '',
          section: data['section'] ?? '',
          loginUsername: data['loginUsername'] ?? '',
          loginPassword: data['loginPassword'] ?? '',
        );
      }).toList();
      notifyListeners();
    });

    // Listen to Classes
    db.collection('classes').snapshots().listen((snapshot) {
      _classes = snapshot.docs.map((doc) {
        final data = doc.data();
        final rawLectures = data['lectureTeachers'] as List<dynamic>? ?? [];
        final lectures = rawLectures.map((l) => SubjectTeacherEntry(
          subject: l['subject'] ?? '', teacherId: l['teacherId'] ?? '', teacherName: l['teacherName'] ?? ''
        )).toList();
        return ClassModel(
          id: doc.id,
          name: data['name'] ?? '',
          section: data['section'] ?? '',
          totalStudents: data['totalStudents'] ?? 0,
          classTeacherId: data['classTeacherId'] ?? '',
          classTeacherName: data['classTeacherName'] ?? '',
          subjects: List<String>.from(data['subjects'] ?? []),
          lectureTeachers: lectures,
        );
      }).toList();
      notifyListeners();
    });

    // Listen to Subjects
    db.collection('settings').doc('subjects').snapshots().listen((doc) {
      if (doc.exists) {
        _globalSubjects = List<String>.from(doc.data()?['list'] ?? []);
        notifyListeners();
      }
    });

    // Listen to Notifications
    db.collection('notifications').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel(
          id: doc.id,
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          type: data['type'] ?? 'info',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          targetRole: data['targetRole'],
          readBy: Map<String, String>.from(data['readBy'] ?? {}),
        );
      }).toList();
      notifyListeners();
    });
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  // ──── TEACHER CRUD ────────────────────────────────────────────────────
  void addTeacher(TeacherModel teacher) async {
    try {
      // In a real scenario, you'd use a Cloud Function to create a user account securely.
      // Here we assume it's created or we just store the profile.
      await FirebaseFirestore.instance.collection('teachers').doc(teacher.id).set({
        'name': teacher.name,
        'subject': teacher.subject,
        'assignedClass': teacher.assignedClass,
        'experience': teacher.experience,
        'email': teacher.email,
        'phone': teacher.phone,
        'qualification': teacher.qualification,
        'isActive': teacher.isActive,
        'loginUsername': teacher.loginUsername,
        'loginPassword': teacher.loginPassword,
      });

      await FirebaseFirestore.instance.collection('users').doc(teacher.id).set({
        'username': teacher.loginUsername,
        'email': teacher.email,
        'role': 'teacher',
        'firstName': teacher.name.split(' ').first,
        'lastName': teacher.name.split(' ').length > 1 ? teacher.name.split(' ').last : '',
        'loginPassword': teacher.loginPassword,
      });
    } catch (e) { print(e); }
  }

  void removeTeacher(String id) async {
    await FirebaseFirestore.instance.collection('teachers').doc(id).delete();
    await FirebaseFirestore.instance.collection('users').doc(id).delete();
  }

  void updateTeacher(TeacherModel updated) async {
    await FirebaseFirestore.instance.collection('teachers').doc(updated.id).update({
      'name': updated.name,
      'subject': updated.subject,
      'assignedClass': updated.assignedClass,
      'experience': updated.experience,
      'email': updated.email,
      'phone': updated.phone,
      'qualification': updated.qualification,
    });
  }

  // ──── STUDENT CRUD ────────────────────────────────────────────────────
  void addStudent(StudentModel student) async {
    await FirebaseFirestore.instance.collection('students').doc(student.id).set({
      'name': student.name,
      'rollNumber': student.rollNumber,
      'className': student.className,
      'section': student.section,
      'loginUsername': student.loginUsername,
      'loginPassword': student.loginPassword,
    });

    await FirebaseFirestore.instance.collection('users').doc(student.id).set({
      'username': student.loginUsername,
      'email': '${student.loginUsername}@schoolapp.com',
      'role': 'student',
      'firstName': student.name.split(' ').first,
      'lastName': student.name.split(' ').length > 1 ? student.name.split(' ').last : '',
      'loginPassword': student.loginPassword,
    });
  }

  void removeStudent(String id) async {
    await FirebaseFirestore.instance.collection('students').doc(id).delete();
    await FirebaseFirestore.instance.collection('users').doc(id).delete();
  }

  void updateTeacherPassword(String id, String newPassword) async {
    await FirebaseFirestore.instance.collection('teachers').doc(id).update({'loginPassword': newPassword});
    await FirebaseFirestore.instance.collection('users').doc(id).update({'loginPassword': newPassword});
  }

  void updateStudentPassword(String id, String newPassword) async {
    await FirebaseFirestore.instance.collection('students').doc(id).update({'loginPassword': newPassword});
    await FirebaseFirestore.instance.collection('users').doc(id).update({'loginPassword': newPassword});
  }

  // ──── CLASS CRUD ──────────────────────────────────────────────────────
  void addClass(ClassModel cls) async {
    await FirebaseFirestore.instance.collection('classes').doc(cls.id).set({
      'name': cls.name,
      'section': cls.section,
      'totalStudents': cls.totalStudents,
      'classTeacherId': cls.classTeacherId,
      'classTeacherName': cls.classTeacherName,
      'subjects': cls.subjects,
      'lectureTeachers': cls.lectureTeachers.map((l) => {
        'subject': l.subject, 'teacherId': l.teacherId, 'teacherName': l.teacherName
      }).toList(),
    });
  }

  void updateClass(ClassModel updated) async {
    await FirebaseFirestore.instance.collection('classes').doc(updated.id).update({
      'name': updated.name,
      'section': updated.section,
      'totalStudents': updated.totalStudents,
      'classTeacherId': updated.classTeacherId,
      'classTeacherName': updated.classTeacherName,
      'subjects': updated.subjects,
      'lectureTeachers': updated.lectureTeachers.map((l) => {
        'subject': l.subject, 'teacherId': l.teacherId, 'teacherName': l.teacherName
      }).toList(),
    });
  }

  void deleteClass(String id) async {
    await FirebaseFirestore.instance.collection('classes').doc(id).delete();
  }

  // ──── SUBJECT CRUD ────────────────────────────────────────────────────
  void addSubject(String subject) async {
    final list = List<String>.from(_globalSubjects);
    if (!list.contains(subject)) {
      list.add(subject);
      await FirebaseFirestore.instance.collection('settings').doc('subjects').set({'list': list});
    }
  }

  void removeSubject(String subject) async {
    final list = List<String>.from(_globalSubjects)..remove(subject);
    await FirebaseFirestore.instance.collection('settings').doc('subjects').set({'list': list});
  }

  // ──── NOTIFICATION ────────────────────────────────────────────────────
  void sendNotification(String title, String message, String type, {String? targetRole}) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'targetRole': targetRole,
      'readBy': {},
    });
  }

  void markNotificationRead(String notificationId, String userId, String userName) async {
    await FirebaseFirestore.instance.collection('notifications').doc(notificationId).set({
      'readBy': {userId: userName}
    }, SetOptions(merge: true));
  }

  // ──── ATTENDANCE ──────────────────────────────────────────────────────
  final Map<String, Map<String, double>> _classAttendanceHistory = {};

  double getAttendanceForClass(String classId, DateTime date) {
    final dateKey = date.toString().split(' ')[0];
    return _classAttendanceHistory[classId]?[dateKey] ?? 85.0;
  }

  // ──── TIMETABLE ───────────────────────────────────────────────────────
  Future<void> sendTimetable(String classId, String fileUrl) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    final className = _classes.firstWhere((c) => c.id == classId).name;
    sendNotification('New Timetable', 'A new timetable has been published for $className.', 'info');
    _isLoading = false;
    notifyListeners();
  }
}
