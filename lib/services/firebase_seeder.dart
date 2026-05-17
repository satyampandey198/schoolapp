import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseSeeder {
  static Future<void> seedDatabase() async {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;

    print('Starting Firebase Seeding...');

    try {
      // 1. Create 2 Admins
      await _createAdmin(auth, db, 'RVAD001', 'Admin@123', 'Principal', 'Sharma');
      await _createAdmin(auth, db, 'RVAD002', 'Admin@123', 'Vice Principal', 'Verma');

      // 2. Create 10 Teachers
      final subjects = ['Mathematics', 'Science', 'English', 'Hindi', 'History', 'Geography', 'Physics', 'Chemistry'];
      
      for (int i = 1; i <= 10; i++) {
        final idNum = i.toString().padLeft(3, '0');
        final username = 'RVTH$idNum';
        final password = 'Teacher@123';
        final name = 'Teacher $i';
        final subject = subjects[i % subjects.length];
        
        await _createTeacher(auth, db, username, password, name, subject, i);
        await Future.delayed(const Duration(milliseconds: 500)); // Anti-spam delay
      }

      // 3. Create Classes 1 to 10 with Sections A and B
      final classesInfo = <Map<String, String>>[];
      for (int i = 1; i <= 10; i++) {
        classesInfo.add({'name': 'Class $i', 'section': 'A'});
        classesInfo.add({'name': 'Class $i', 'section': 'B'});
      }

      for (var cls in classesInfo) {
        final className = cls['name']!;
        final section = cls['section']!;
        final classId = 'c_${className.replaceAll(' ', '')}_$section';
        
        await db.collection('classes').doc(classId).set({
          'name': className,
          'section': section,
          'totalStudents': 10,
          'classTeacherId': '',
          'classTeacherName': '',
          'subjects': ['Mathematics', 'Science', 'English'],
          'lectureTeachers': [],
        });
      }

      // 4. Create 10 Students per Class (Total 200)
      int studentCounter = 1;
      for (var cls in classesInfo) {
        final className = cls['name']!;
        final section = cls['section']!;
        
        for (int i = 1; i <= 10; i++) {
          final idNum = studentCounter.toString().padLeft(3, '0');
          final username = 'RVST$idNum';
          final password = 'Student@123';
          final name = 'Student $idNum';
          final rollNumber = 'R${idNum}';
          
          await _createStudent(auth, db, username, password, name, rollNumber, className, section);
          studentCounter++;
          await Future.delayed(const Duration(milliseconds: 300)); // Anti-spam delay
        }
      }

      print('✅ Database Seeding Completed Successfully!');
    } catch (e) {
      print('❌ Seeding Error: $e');
    }
  }

  static Future<void> _createAdmin(FirebaseAuth auth, FirebaseFirestore db, String username, String password, String firstName, String lastName) async {
    try {
      final email = '${username.toLowerCase()}@schoolapp.com';
      final uid = 'uid_$username';
      await db.collection('users').doc(uid).set({
        'id': uid,
        'username': username,
        'email': email,
        'role': 'admin',
        'firstName': firstName,
        'lastName': lastName,
        'loginPassword': password,
      });
      print('Created Admin: $username');
    } catch (e) {
      print('Admin exists or error: $e');
    }
  }

  static Future<void> _createTeacher(FirebaseAuth auth, FirebaseFirestore db, String username, String password, String name, String subject, int index) async {
    try {
      final email = '${username.toLowerCase()}@schoolapp.com';
      final uid = 'uid_$username';
      
      await db.collection('users').doc(uid).set({
        'id': uid,
        'username': username,
        'email': email,
        'role': 'teacher',
        'firstName': name,
        'lastName': '',
        'loginPassword': password,
      });

      await db.collection('teachers').doc(uid).set({
        'id': uid,
        'name': name,
        'subject': subject,
        'assignedClass': '',
        'experience': '${(index % 10) + 1} Years',
        'email': email,
        'phone': '+91 90000 000${index.toString().padLeft(2, '0')}',
        'qualification': 'M.A. / M.Sc.',
        'isActive': true,
        'loginUsername': username,
        'loginPassword': password,
      });

      print('Created Teacher: $name ($username)');
    } catch (e) {
      print('Teacher exists or error: $e');
    }
  }

  static Future<void> _createStudent(FirebaseAuth auth, FirebaseFirestore db, String username, String password, String name, String rollNumber, String className, String section) async {
    try {
      final email = '${username.toLowerCase()}@schoolapp.com';
      final uid = 'uid_$username';
      
      await db.collection('users').doc(uid).set({
        'id': uid,
        'username': username,
        'email': email,
        'role': 'student',
        'firstName': name,
        'lastName': '',
        'loginPassword': password,
      });

      await db.collection('students').doc(uid).set({
        'id': uid,
        'name': name,
        'rollNumber': rollNumber,
        'className': className,
        'section': section,
        'loginUsername': username,
        'loginPassword': password,
      });

      print('Created Student: $name ($username) for $className-$section');
    } catch (e) {
      print('Student exists or error: $e');
    }
  }
}
