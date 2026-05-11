import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF23023F),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('User Profile Detail Coming Soon', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
