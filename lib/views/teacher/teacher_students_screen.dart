import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';
import '../../models/student_model.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherViewModel>();
    final cs = Theme.of(context).colorScheme;

    final filteredStudents = vm.classStudents.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(query) || s.rollNumber.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Students')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name or roll number...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text('No students found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredStudents.length,
                    itemBuilder: (ctx, i) {
                      final s = filteredStudents[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: cs.primary.withValues(alpha: 0.1),
                              child: Text(s.name[0], style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  Text('${s.className} - ${s.section} • Roll: ${s.rollNumber}',
                                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline_rounded),
                              onPressed: () {
                                _showStudentInfo(context, s);
                              },
                            )
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: i * 40));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showStudentInfo(BuildContext context, StudentModel s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Roll Number: ${s.rollNumber}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('Class: ${s.className} - ${s.section}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          ],
        ),
      ),
    );
  }
}
