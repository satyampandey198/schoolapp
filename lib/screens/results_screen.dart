import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Results'),
        backgroundColor: const Color(0xFF33145E),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Academic Results & Report Cards Coming Soon', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
