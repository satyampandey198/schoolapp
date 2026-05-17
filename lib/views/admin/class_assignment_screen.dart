import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../widgets/buttons/custom_button.dart';

class ClassAssignmentScreen extends StatefulWidget {
  const ClassAssignmentScreen({super.key});

  @override
  State<ClassAssignmentScreen> createState() => _ClassAssignmentScreenState();
}

class _ClassAssignmentScreenState extends State<ClassAssignmentScreen> {
  String? _selectedTeacher;
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedSection;
  bool _isSaving = false;

  static const _subjects = ['Mathematics', 'English', 'Science', 'Hindi', 'History', 'Geography', 'Physics', 'Chemistry'];
  static const _classNames = ['Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'];
  static const _sections = ['A', 'B', 'C', 'D'];

  Future<void> _save() async {
    if (_selectedTeacher == null || _selectedSubject == null || _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment saved!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Class Assignment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Assignment form card
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
                  Text('New Assignment', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  _buildDropdown('Select Teacher', _selectedTeacher, Icons.person_rounded,
                      vm.teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                      (v) => setState(() => _selectedTeacher = v)),
                  const SizedBox(height: 14),
                  _buildDropdown('Select Subject', _selectedSubject, Icons.book_rounded,
                      _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      (v) => setState(() => _selectedSubject = v)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown('Class', _selectedClass, Icons.class_rounded,
                            _classNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            (v) => setState(() => _selectedClass = v)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown('Section', _selectedSection, Icons.label_rounded,
                            _sections.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            (v) => setState(() => _selectedSection = v)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(label: 'Save Assignment', onPressed: _save, isLoading: _isSaving, icon: Icons.save_rounded),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current assignments
            Text('Current Assignments', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            ...vm.classes.map((c) => Container(
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
                    child: Icon(Icons.class_rounded, color: cs.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.displayName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text('${c.teacherName} • ${c.totalStudents} students',
                            style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    children: c.subjects.take(2).map((s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 10)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, IconData icon,
      List<DropdownMenuItem<String>> items, void Function(String?) onChange) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: items,
      onChanged: onChange,
    );
  }
}
