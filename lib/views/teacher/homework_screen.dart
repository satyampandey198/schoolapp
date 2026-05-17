import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/buttons/custom_button.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedSubject = 'Mathematics';
  String _selectedClass = 'Class 10-A';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 3));
  bool _isSaving = false;

  static const _subjects = ['Mathematics', 'English', 'Science', 'Hindi', 'History'];
  static const _classes = ['Class 6-A', 'Class 7-A', 'Class 8-A', 'Class 9-A', 'Class 10-A'];

  final List<Map<String, String>> _posted = [
    {'title': 'Chapter 5 Exercises', 'subject': 'Mathematics', 'class': 'Class 10-A', 'due': 'Tomorrow'},
    {'title': 'Essay: Environment', 'subject': 'English', 'class': 'Class 9-B', 'due': 'Friday'},
    {'title': 'Lab Report', 'subject': 'Science', 'class': 'Class 10-A', 'due': 'Next Monday'},
  ];

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a homework title')),
      );
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _posted.insert(0, {
        'title': _titleCtrl.text.trim(),
        'subject': _selectedSubject,
        'class': _selectedClass,
        'due': '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
      });
      _isSaving = false;
      _titleCtrl.clear();
      _descCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Homework posted!'), backgroundColor: Colors.green),
    );
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
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Add details about the homework…',
                      prefixIcon: const Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedClass,
                          decoration: InputDecoration(
                            labelText: 'Class',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _selectedClass = v!),
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

            ..._posted.asMap().entries.map((entry) {
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
                          Text(hw['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${hw['subject']} • ${hw['class']}',
                              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Text('Due ${hw['due']}',
                          style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600)),
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
