import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF031E07),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Notification Alerts Coming Soon', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
