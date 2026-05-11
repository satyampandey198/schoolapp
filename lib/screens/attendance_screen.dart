import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: const Color(0xFF182033),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Attendance Data Coming Soon', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
