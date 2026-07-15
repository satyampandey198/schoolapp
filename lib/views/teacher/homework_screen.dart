import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';
import '../../models/homework_model.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<TextEditingController> _instructionCtrls = [TextEditingController()];
  
  String _selectedSubject = 'Mathematics';
  String _selectedClassId = ''; // We will default this later
  DateTime _dueDate = DateTime.now().add(const Duration(days: 3));
  bool _isSaving = false;

  static const _subjects = ['Mathematics', 'English', 'Science', 'Hindi', 'History'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (var c in _instructionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addInstructionField() {
    setState(() {
      _instructionCtrls.add(TextEditingController());
    });
  }

  void _removeInstructionField(int index) {
    if (_instructionCtrls.length > 1) {
      setState(() {
        final ctrl = _instructionCtrls.removeAt(index);
        ctrl.dispose();
      });
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a homework title')),
      );
      return;
    }
    
    final teacherVM = context.read<TeacherViewModel>();
    final auth = context.read<AuthViewModel>();
    final teacherClass = teacherVM.teacherModel?.assignedClass ?? '';
    final classId = _selectedClassId.isEmpty
        ? (teacherClass.isNotEmpty
            ? 'c_${teacherClass.replaceAll(' ', '').replaceAll('-', '_')}'
            : 'c_Class1_A')
        : _selectedClassId;
    final userId = auth.currentUser?.id ?? 'unknown_teacher';
    
    final instructions = _instructionCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    setState(() => _isSaving = true);

    try {
      final hw = HomeworkModel(
        id: '', // Firestore will generate
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        subject: _selectedSubject,
        classId: classId,
        dueDate: _dueDate,
        teacherId: userId,
        instructions: instructions,
        createdAt: DateTime.now(),
      );

      await context.read<TeacherViewModel>().addHomework(hw);

      if (!mounted) return;
      
      setState(() {
        _titleCtrl.clear();
        _descCtrl.clear();
        for (var c in _instructionCtrls) { c.dispose(); }
        _instructionCtrls.clear();
        _instructionCtrls.add(TextEditingController());
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Homework posted!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final postedHomework = context.watch<TeacherViewModel>().homeworkList;

    return Scaffold(
      appBar: AppBar(title: const Text('Homework & Notes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Homework', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Homework Title',
                      hintText: 'e.g. Chapter 5 Exercises',
                      prefixIcon: const Icon(Icons.assignment_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Add details about the homework…',
                      prefixIcon: const Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // Multiple Instructions
                  Text('Instructions/Notes', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                  const SizedBox(height: 8),
                  ..._instructionCtrls.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var ctrl = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrl,
                              decoration: InputDecoration(
                                hintText: 'Instruction ${idx + 1}',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          if (_instructionCtrls.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removeInstructionField(idx),
                            ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: _addInstructionField,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add another instruction'),
                  ),

                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _selectedSubject = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 18, color: cs.primary),
                          const SizedBox(width: 10),
                          Text('Due: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down_rounded, color: cs.onSurface.withValues(alpha: 0.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(label: 'Post Homework', onPressed: _save, isLoading: _isSaving, icon: Icons.send_rounded),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),
            Text('Posted Homework', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),

            if (postedHomework.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('No homework posted yet.', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
                ),
              ),

            ...postedHomework.asMap().entries.map((entry) {
              final i = entry.key;
              final hw = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.assignment_rounded, color: cs.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hw.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${hw.subject} • Due: ${hw.dueDate.day}/${hw.dueDate.month}/${hw.dueDate.year}',
                              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                          if (hw.instructions.isNotEmpty)
                             Text('${hw.instructions.length} instructions', style: TextStyle(fontSize: 11, color: cs.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: i * 60)).slideX(begin: -0.05, end: 0);
            }),
          ],
        ),
      ),
    );
  }
}
