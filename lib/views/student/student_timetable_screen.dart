import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/student/student_viewmodel.dart';
import '../../widgets/timetable/timetable_card.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _days.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _days.map((d) => Tab(text: d.substring(0, 3))).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: _days.map((day) {
          final entries = vm.timetable.where((e) => e.day == day).toList();
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_rounded, size: 60, color: cs.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text('No classes on $day',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (_, i) => TimetableCard(entry: entries[i])
                .animate()
                .fadeIn(delay: Duration(milliseconds: i * 80))
                .slideX(begin: -0.1, end: 0),
          );
        }).toList(),
      ),
    );
  }
}
