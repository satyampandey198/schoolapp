import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../models/exam_model.dart';

class AdminExamsScreen extends StatefulWidget {
  const AdminExamsScreen({super.key});

  @override
  State<AdminExamsScreen> createState() => _AdminExamsScreenState();
}

class _AdminExamsScreenState extends State<AdminExamsScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final exams = vm.exams;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Exams')),
      body: exams.isEmpty
          ? const Center(child: Text('No exams scheduled yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text('${exam.name} - ${exam.subject}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Class ID: ${exam.classId}'),
                        Text('Date: ${DateFormat('MMM d, yyyy').format(exam.date)}'),
                        Text('Time: ${exam.startTime} to ${exam.endTime}'),
                        Text('Total Marks: ${exam.totalMarks}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteExam(context, vm, exam.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExamDialog(context, vm),
        icon: const Icon(Icons.add),
        label: const Text('New Exam'),
      ),
    );
  }

  void _deleteExam(BuildContext context, AdminViewModel vm, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              vm.deleteExam(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddExamDialog(BuildContext context, AdminViewModel vm) {
    final formKey = GlobalKey<FormState>();
    String name = 'Unit Test';
    String subject = '';
    String classId = '';
    DateTime date = DateTime.now();
    String startTime = '10:00 AM';
    String endTime = '12:00 PM';
    int totalMarks = 100;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Schedule New Exam', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Exam Name', border: OutlineInputBorder()),
                    value: name,
                    items: ['Unit Test', 'Mid Term', 'Final Exam', 'Practical']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => name = v!,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                    value: vm.classes.isNotEmpty ? vm.classes.first.id : null,
                    items: vm.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => classId = v ?? '',
                    validator: (v) => v == null ? 'Select Class' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                    value: vm.globalSubjects.isNotEmpty ? vm.globalSubjects.first : null,
                    items: vm.globalSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => subject = v ?? '',
                    validator: (v) => v == null ? 'Select Subject' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: totalMarks.toString(),
                          decoration: const InputDecoration(labelText: 'Total Marks', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid number' : null,
                          onSaved: (v) => totalMarks = int.parse(v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime(2030));
                            if (d != null) date = d;
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                            child: Text(DateFormat('MMM d, yyyy').format(date)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: startTime,
                          decoration: const InputDecoration(labelText: 'Start Time', border: OutlineInputBorder()),
                          onSaved: (v) => startTime = v!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: endTime,
                          decoration: const InputDecoration(labelText: 'End Time', border: OutlineInputBorder()),
                          onSaved: (v) => endTime = v!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        if (classId.isEmpty || subject.isEmpty) return;

                        final exam = ExamModel(
                          id: '',
                          name: name,
                          subject: subject,
                          classId: classId,
                          date: date,
                          startTime: startTime,
                          endTime: endTime,
                          totalMarks: totalMarks,
                        );

                        vm.addExam(exam);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam Scheduled')));
                      }
                    },
                    child: const Text('Save Exam'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
