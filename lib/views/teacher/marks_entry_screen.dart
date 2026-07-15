import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';
import '../../models/exam_model.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/shimmer_loader.dart';

class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  ExamModel? _selectedExam;

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
    
    // Filter exams by subjects assigned to this teacher
    final teacherExams = vm.exams.where((e) => vm.assignedSubjects.contains(e.subject)).toList();
    if (_selectedExam == null && teacherExams.isNotEmpty) {
      _selectedExam = teacherExams.first;
    }

    // Filter marks for selected exam
    final filteredMarks = _selectedExam == null ? [] : vm.marks.where((m) => m.examId == _selectedExam!.id).toList();
    
    // Cross-reference with class students to ensure all students have an entry row
    // In a real app we might only fetch students for _selectedExam!.classId
    final classStudents = vm.classStudents; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks Entry'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marks saved automatically!'), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<ExamModel>(
              decoration: InputDecoration(
                labelText: 'Select Exam',
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: _selectedExam,
              items: teacherExams.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text('${e.name} - ${e.subject} (${DateFormat('MMM d').format(e.date)})'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedExam = v),
              hint: const Text('Select an exam to enter marks'),
            ),
          ),
          if (_selectedExam != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Class ID: ${_selectedExam!.classId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Total Marks: ${_selectedExam!.totalMarks}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
          const Divider(height: 16),
          Expanded(
            child: vm.isLoadingDashboard 
                ? const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: ShimmerList(count: 6, itemHeight: 60))
                : _selectedExam == null
                ? const Center(child: Text('No exams found for your assigned subjects.'))
                : classStudents.isEmpty
                    ? const Center(child: Text('No students in this class.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: classStudents.length,
                        itemBuilder: (_, i) {
                          final student = classStudents[i];
                          // We use a safe getter for UI mapping if it doesn't exist yet
                          final hasMark = filteredMarks.any((mark) => mark.studentId == student.id);
                          final currentMark = hasMark ? filteredMarks.firstWhere((mark) => mark.studentId == student.id) : null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: cs.surface, 
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(student.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    Text(student.rollNumber, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55))),
                                  ],
                                )),
                                SizedBox(
                                  width: 70,
                                  child: TextFormField(
                                    initialValue: currentMark?.marks.toString() ?? '',
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: '-',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onChanged: (v) {
                                      final val = int.tryParse(v);
                                      if (val != null) {
                                        try {
                                          context.read<TeacherViewModel>().updateMark(
                                            student.id, val,
                                            examId: _selectedExam!.id,
                                            subject: _selectedExam!.subject,
                                            examType: _selectedExam!.name,
                                            studentName: student.name,
                                            rollNumber: student.rollNumber,
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (currentMark != null)
                                  Container(
                                    width: 32,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _gradeColor(currentMark.grade).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(currentMark.grade,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _gradeColor(currentMark.grade))),
                                  )
                                else
                                  const SizedBox(width: 32),
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
