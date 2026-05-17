import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';

class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  String? _selectedSubject;

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+': return Colors.green;
      case 'A':  return Colors.teal;
      case 'B':  return Colors.blue;
      case 'C':  return Colors.orange;
      default:   return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherViewModel>();
    final cs = Theme.of(context).colorScheme;
    final subjects = vm.assignedSubjects;
    if (_selectedSubject == null && subjects.isNotEmpty) {
      _selectedSubject = subjects.first;
    }

    final filteredMarks = vm.marks.where((m) => m.subject == _selectedSubject).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks Entry'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marks saved!'), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: subjects.isEmpty 
              ? const Center(child: Text('No subjects assigned'))
              : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = subjects[i];
                final selected = s == _selectedSubject;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSubject = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? cs.primary : cs.outline.withValues(alpha: 0.4)),
                    ),
                    child: Text(s, style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13,
                      color: selected ? Colors.white : cs.onSurface.withValues(alpha: 0.7))),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: filteredMarks.isEmpty
                ? const Center(child: Text('No students found for this subject.'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredMarks.length,
              itemBuilder: (_, i) {
                final m = filteredMarks[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surface, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.studentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(m.rollNumber, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55))),
                        ],
                      )),
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          initialValue: m.marks.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (v) {
                            final val = (int.tryParse(v) ?? m.marks).clamp(0, 100);
                            context.read<TeacherViewModel>().updateMark(m.studentId, val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: _gradeColor(m.grade).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(m.grade,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _gradeColor(m.grade))),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
