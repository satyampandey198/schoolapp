import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AnnouncementCard(
            title: 'Holiday Notice',
            message: 'School closed due to public holiday.',
            date: '16 Mar',
          ),
          SizedBox(height: 12),
          AnnouncementCard(
            title: 'Exam Notice',
            message: 'Math test tomorrow for all 5th grade students.',
            date: '20 Mar',
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String message;
  final String date;

  const AnnouncementCard({super.key, required this.title, required this.message, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}
