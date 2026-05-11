import 'package:flutter/material.dart';

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HomeworkCard(
            subject: 'Math',
            homework: 'Page 34 Q1–10',
            due: 'Tomorrow',
          ),
          SizedBox(height: 12),
          HomeworkCard(
            subject: 'Science',
            homework: 'Chapter 3 Reading',
            due: 'Thursday',
          ),
        ],
      ),
    );
  }
}

class HomeworkCard extends StatelessWidget {
  final String subject;
  final String homework;
  final String due;

  const HomeworkCard({super.key, required this.subject, required this.homework, required this.due});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject: $subject', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
            const SizedBox(height: 8),
            Text('Homework: $homework'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Due: $due', style: const TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
