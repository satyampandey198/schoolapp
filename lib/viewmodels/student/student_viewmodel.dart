import 'package:flutter/material.dart';
import '../../models/lecture_model.dart';
import '../../models/notification_model.dart';

class StudentViewModel extends ChangeNotifier {
  double attendancePercentage = 87.5;
  int pendingHomework = 3;
  List<TimetableEntry> timetable = [];
  List<NotificationModel> notifications = [];
  List<Map<String, dynamic>> results = [];
  List<Map<String, dynamic>> homework = [];

  StudentViewModel() {
    _loadMockData();
  }

  void _loadMockData() {
    timetable = [
      const TimetableEntry(day: 'Monday', subject: 'Mathematics', time: '08:00 - 09:00', room: 'Room 101', teacher: 'Mr. Rajesh'),
      const TimetableEntry(day: 'Monday', subject: 'English', time: '09:00 - 10:00', room: 'Room 203', teacher: 'Ms. Priya'),
      const TimetableEntry(day: 'Monday', subject: 'Science', time: '10:30 - 11:30', room: 'Room 105', teacher: 'Mr. Ankit'),
      const TimetableEntry(day: 'Tuesday', subject: 'Hindi', time: '08:00 - 09:00', room: 'Room 102', teacher: 'Ms. Sunita'),
      const TimetableEntry(day: 'Tuesday', subject: 'History', time: '09:00 - 10:00', room: 'Room 204', teacher: 'Mr. Mohan'),
      const TimetableEntry(day: 'Tuesday', subject: 'Mathematics', time: '10:30 - 11:30', room: 'Room 101', teacher: 'Mr. Rajesh'),
      const TimetableEntry(day: 'Wednesday', subject: 'Science', time: '08:00 - 09:00', room: 'Room 105', teacher: 'Mr. Ankit'),
      const TimetableEntry(day: 'Wednesday', subject: 'English', time: '09:00 - 10:00', room: 'Room 203', teacher: 'Ms. Priya'),
      const TimetableEntry(day: 'Thursday', subject: 'Mathematics', time: '08:00 - 09:00', room: 'Room 101', teacher: 'Mr. Rajesh'),
      const TimetableEntry(day: 'Friday', subject: 'Hindi', time: '08:00 - 09:00', room: 'Room 102', teacher: 'Ms. Sunita'),
    ];
    notifications = [
      NotificationModel(id: 'n1', title: 'Exam Schedule', message: 'Mid-term exams start June 10.', type: 'info', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
      NotificationModel(id: 'n2', title: 'Homework Due', message: 'Math homework due tomorrow.', type: 'warning', createdAt: DateTime.now().subtract(const Duration(hours: 5))),
      NotificationModel(id: 'n3', title: 'Results Published', message: 'Unit test results are now available.', type: 'success', createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ];
    results = [
      {'subject': 'Mathematics', 'marks': 88, 'total': 100, 'grade': 'A'},
      {'subject': 'English', 'marks': 76, 'total': 100, 'grade': 'B'},
      {'subject': 'Science', 'marks': 92, 'total': 100, 'grade': 'A+'},
      {'subject': 'Hindi', 'marks': 81, 'total': 100, 'grade': 'A'},
      {'subject': 'History', 'marks': 68, 'total': 100, 'grade': 'B'},
    ];
    homework = [
      {'subject': 'Mathematics', 'title': 'Chapter 5 Exercises', 'due': 'Tomorrow', 'status': 'pending'},
      {'subject': 'Science', 'title': 'Lab Report – Photosynthesis', 'due': 'Friday', 'status': 'pending'},
      {'subject': 'English', 'title': 'Essay: My Hero', 'due': 'Next Monday', 'status': 'submitted'},
    ];
    notifyListeners();
  }
}
