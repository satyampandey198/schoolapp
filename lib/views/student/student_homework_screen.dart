import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/student/student_viewmodel.dart';
import '../../models/homework_model.dart';

class StudentHomeworkScreen extends StatelessWidget {
  const StudentHomeworkScreen({super.key});

  void _showHomeworkDetails(BuildContext context, HomeworkModel hw) {
    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(hw.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Subject: ${hw.subject}',
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: cs.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(width: 8),
                    Text('Due: ${hw.dueDate.day}/${hw.dueDate.month}/${hw.dueDate.year}',
                        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
                  ],
                ),
                if (hw.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(hw.description, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.8))),
                ],
                if (hw.instructions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Instructions & Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...hw.instructions.map((inst) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(inst)),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final homeworkList = context.watch<StudentViewModel>().homework;

    return Scaffold(
      appBar: AppBar(title: const Text('All Homework')),
      body: homeworkList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in, size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text('No homework assigned', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: homeworkList.length,
              itemBuilder: (context, i) {
                final hw = homeworkList[i];
                return GestureDetector(
                  onTap: () => _showHomeworkDetails(context, hw),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.assignment_outlined, color: cs.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hw.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(hw.subject, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Due', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
                            Text('${hw.dueDate.day}/${hw.dueDate.month}', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                          ],
                        )
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: i * 50)).slideY(begin: 0.1, end: 0),
                );
              },
            ),
    );
  }
}
