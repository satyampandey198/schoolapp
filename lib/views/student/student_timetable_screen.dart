import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/student/student_viewmodel.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/shimmer_loader.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Class Timetable')),
                ButtonSegment(value: 1, label: Text('Exam Timetable')),
              ],
              selected: {_selectedIndex},
              onSelectionChanged: (set) {
                setState(() => _selectedIndex = set.first);
              },
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? _buildClassTimetable(vm, cs)
                : _buildExamTimetable(vm, cs),
          ),
        ],
      ),
    );
  }

  Widget _buildClassTimetable(StudentViewModel vm, ColorScheme cs) {
    if (vm.isLoadingDashboard) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerList(count: 5, itemHeight: 100),
      );
    }
    if (vm.lectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 60, color: cs.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('No classes scheduled', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vm.lectures.length,
      itemBuilder: (context, i) {
        final entry = vm.lectures[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.class_rounded, color: cs.onPrimaryContainer),
            ),
            title: Text(entry.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Date: ${DateFormat('MMM d, yyyy').format(entry.date)}\nTime: ${entry.startTime} - ${entry.endTime}\nTeacher: ${entry.teacherName}'),
            isThreeLine: true,
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 80)).slideX(begin: -0.1, end: 0);
      },
    );
  }

  Widget _buildExamTimetable(StudentViewModel vm, ColorScheme cs) {
    if (vm.isLoadingDashboard) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ShimmerList(count: 5, itemHeight: 120),
      );
    }
    if (vm.exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_rounded, size: 60, color: cs.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('No exams scheduled', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vm.exams.length,
      itemBuilder: (context, i) {
        final exam = vm.exams[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.surface, cs.primaryContainer.withValues(alpha: 0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('MMM').format(exam.date).toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
                      Text(DateFormat('d').format(exam.date), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cs.primary)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam.subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(exam.name, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text('${exam.startTime} - ${exam.endTime}', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7))),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
                    Text(exam.totalMarks.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 80)).slideX(begin: 0.1, end: 0);
      },
    );
  }
}
