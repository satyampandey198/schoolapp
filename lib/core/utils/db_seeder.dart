import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DbSeeder {
  static Future<void> seedAll() async {
    final db = FirebaseFirestore.instance;
    final uuid = const Uuid();

    // 1. Subjects
    final subjects = ['Mathematics', 'Science', 'English', 'History', 'Geography', 'Physics', 'Chemistry', 'Biology', 'Computer Science', 'Art'];
    await db.collection('settings').doc('subjects').set({'list': subjects});

    // 2. Teachers
    List<Map<String, dynamic>> teacherDocs = [];
    for (int i = 0; i < 10; i++) {
      final tId = uuid.v4();
      final subj = subjects[i];
      final username = 'RVTC${1000 + i}';
      
      final teacherData = {
        'name': 'Teacher ${i + 1}',
        'subject': subj,
        'assignedClass': 'Class ${i + 1}-A',
        'experience': '${2 + i} Years',
        'email': 'teacher${i+1}@school.com',
        'phone': '987654321$i',
        'qualification': 'M.Sc, B.Ed',
        'isActive': true,
        'loginUsername': username,
        'loginPassword': 'Teacher@123',
      };
      
      await db.collection('teachers').doc(tId).set(teacherData);
      await db.collection('users').doc(tId).set({
        'username': username,
        'email': teacherData['email'],
        'role': 'teacher',
        'firstName': 'Teacher',
        'lastName': '${i+1}',
        'loginPassword': 'Teacher@123',
      });
      teacherDocs.add({'id': tId, ...teacherData});
    }

    // 3. Classes & Students & Timetables & Exams
    for (int i = 0; i < 10; i++) {
      final classId = 'c_Class${i+1}_A';
      final className = 'Class ${i+1}';
      final section = 'A';
      
      final classTeacher = teacherDocs[i];

      // Assign random lecture teachers from our generated pool
      final lectureTeachers = [
        {'subject': subjects[(i) % 10], 'teacherId': teacherDocs[(i) % 10]['id'], 'teacherName': teacherDocs[(i) % 10]['name']},
        {'subject': subjects[(i+1) % 10], 'teacherId': teacherDocs[(i+1) % 10]['id'], 'teacherName': teacherDocs[(i+1) % 10]['name']},
        {'subject': subjects[(i+2) % 10], 'teacherId': teacherDocs[(i+2) % 10]['id'], 'teacherName': teacherDocs[(i+2) % 10]['name']},
      ];

      await db.collection('classes').doc(classId).set({
        'name': className,
        'section': section,
        'totalStudents': 5,
        'classTeacherId': classTeacher['id'],
        'classTeacherName': classTeacher['name'],
        'subjects': [subjects[(i) % 10], subjects[(i+1) % 10], subjects[(i+2) % 10]],
        'lectureTeachers': lectureTeachers,
      });

      // Students for this class
      for (int j = 0; j < 5; j++) {
        final sId = uuid.v4();
        final rollNo = '${i+1}00${j+1}';
        final username = 'RVST$rollNo';

        await db.collection('students').doc(sId).set({
          'name': 'Student ${i+1}.${j+1}',
          'rollNumber': rollNo,
          'className': className,
          'section': section,
          'loginUsername': username,
          'loginPassword': 'Student@123',
        });
        
        await db.collection('users').doc(sId).set({
          'username': username,
          'email': '$username@schoolapp.com',
          'role': 'student',
          'firstName': 'Student',
          'lastName': '${i+1}.${j+1}',
          'loginPassword': 'Student@123',
        });
      }

      // Timetable (Lecture Schedule)
      final date = DateTime.now().toIso8601String().split('T')[0];
      for (int j = 0; j < lectureTeachers.length; j++) {
        await db.collection('lectures').add({
          'classId': classId,
          'className': className,
          'section': section,
          'subject': lectureTeachers[j]['subject'],
          'teacherId': lectureTeachers[j]['teacherId'],
          'teacherName': lectureTeachers[j]['teacherName'],
          'date': date,
          'startTime': '${8 + j}:00 AM',
          'endTime': '${9 + j}:00 AM',
          'status': 'scheduled',
        });
      }

      // Exams
      await db.collection('exams').add({
        'name': 'Mid Term',
        'subject': lectureTeachers[0]['subject'],
        'classId': classId,
        'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'startTime': '10:00 AM',
        'endTime': '1:00 PM',
        'totalMarks': 100,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
