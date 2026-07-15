import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../models/class_model.dart';
import '../../models/teacher_model.dart';
import '../../widgets/buttons/custom_button.dart';

class ManageClassesScreen extends StatefulWidget {
  const ManageClassesScreen({super.key});

  @override
  State<ManageClassesScreen> createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends State<ManageClassesScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showClassDialog(context, vm),
          ),
        ],
      ),
      body: vm.classes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.class_rounded, size: 64, color: cs.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  const Text('No classes yet. Tap + to create one.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.classes.length,
              itemBuilder: (_, i) {
                final c = vm.classes[i];
                return _ClassCard(
                  cls: c,
                  onEdit: () => _showClassDialog(context, vm, existing: c),
                  onDelete: () => _confirmDelete(context, vm, c),
                  onManageTeachers: () => _showTeacherAssignDialog(context, vm, c),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 60)).slideY(begin: 0.1, end: 0);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClassDialog(context, vm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Class'),
      ),
    );
  }

  void _showClassDialog(BuildContext context, AdminViewModel vm, {ClassModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final sectionCtrl = TextEditingController(text: existing?.section ?? '');
    final totalCtrl = TextEditingController(text: existing?.totalStudents.toString() ?? '0');
    String? selectedClassTeacherId = existing?.classTeacherId;
    List<String> selectedSubjects = List.from(existing?.subjects ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20, right: 20, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(existing == null ? 'Create Class' : 'Edit Class',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(labelText: 'Class Name (e.g. Class 10)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: sectionCtrl,
                        decoration: InputDecoration(labelText: 'Section (A/B/C)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Total Students', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedClassTeacherId,
                  decoration: InputDecoration(labelText: 'Class Teacher (Main)', prefixIcon: const Icon(Icons.star_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...vm.teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
                  ],
                  onChanged: (v) => setModalState(() => selectedClassTeacherId = v),
                ),
                const SizedBox(height: 14),
                const Text('Subjects:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: vm.globalSubjects.map((s) {
                    final selected = selectedSubjects.contains(s);
                    return FilterChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (v) => setModalState(() {
                        if (v) selectedSubjects.add(s);
                        else selectedSubjects.remove(s);
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: existing == null ? 'Create Class' : 'Update Class',
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final teacher = selectedClassTeacherId != null
                        ? vm.teachers.firstWhere((t) => t.id == selectedClassTeacherId, orElse: () => const TeacherModel(id: '', name: '', subject: '', assignedClass: '', experience: '', email: '', phone: ''))
                        : null;
                    
                    try {
                      if (existing == null) {
                        await vm.addClass(ClassModel(
                          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          section: sectionCtrl.text.trim(),
                          totalStudents: int.tryParse(totalCtrl.text) ?? 0,
                          classTeacherId: teacher?.id ?? '',
                          classTeacherName: teacher?.name ?? '',
                          subjects: List.from(selectedSubjects),
                        ));
                      } else {
                        await vm.updateClass(existing.copyWith(
                          name: nameCtrl.text.trim(),
                          section: sectionCtrl.text.trim(),
                          totalStudents: int.tryParse(totalCtrl.text) ?? existing.totalStudents,
                          classTeacherId: teacher?.id ?? existing.classTeacherId,
                          classTeacherName: teacher?.name ?? existing.classTeacherName,
                          subjects: List.from(selectedSubjects),
                        ));
                      }
                      if (context.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTeacherAssignDialog(BuildContext context, AdminViewModel vm, ClassModel cls) {
    List<SubjectTeacherEntry> entries = List.from(cls.lectureTeachers);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20, right: 20, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Assign Lecture Teachers — ${cls.displayName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...cls.subjects.map((subject) {
                final existing = entries.where((e) => e.subject == subject).firstOrNull;
                String? selectedTeacherId = existing?.teacherId;
                return StatefulBuilder(builder: (_, setRow) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(subject, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          isDense: true,
                          value: selectedTeacherId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('None')),
                            ...vm.teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name, style: const TextStyle(fontSize: 13)))),
                          ],
                          onChanged: (v) {
                            setRow(() => selectedTeacherId = v);
                            setModalState(() {
                              entries.removeWhere((e) => e.subject == subject);
                              if (v != null) {
                                final teacher = vm.teachers.firstWhere((t) => t.id == v);
                                entries.add(SubjectTeacherEntry(subject: subject, teacherId: v, teacherName: teacher.name));
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ));
              }),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Save Assignments',
                onPressed: () async {
                  try {
                    await vm.updateClass(cls.copyWith(lectureTeachers: entries));
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignments saved!')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminViewModel vm, ClassModel cls) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Delete "${cls.displayName}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async { 
              Navigator.pop(context); 
              try {
                await vm.deleteClass(cls.id); 
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final ClassModel cls;
  final VoidCallback onEdit, onDelete, onManageTeachers;
  const _ClassCard({required this.cls, required this.onEdit, required this.onDelete, required this.onManageTeachers});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.class_rounded, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('${cls.totalStudents} students', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_rounded), title: Text('Edit'))),
                  const PopupMenuItem(value: 'teachers', child: ListTile(leading: Icon(Icons.person_rounded), title: Text('Assign Teachers'))),
                  const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_rounded, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
                ],
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                  if (v == 'teachers') onManageTeachers();
                },
              ),
            ],
          ),
          if (cls.classTeacherName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text('Class Teacher: ${cls.classTeacherName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
          if (cls.subjects.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 4,
              children: cls.subjects.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(s, style: TextStyle(fontSize: 11, color: cs.primary, fontWeight: FontWeight.w500)),
              )).toList(),
            ),
          ],
          if (cls.lectureTeachers.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text('Lecture Teachers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 4),
            ...cls.lectureTeachers.map((lt) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 12),
                  const SizedBox(width: 4),
                  Text('${lt.subject}: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(lt.teacherName, style: const TextStyle(fontSize: 12)),
                ],
              ),
            )),
          ],
          TextButton.icon(
            onPressed: onManageTeachers,
            icon: const Icon(Icons.person_add_rounded, size: 14),
            label: const Text('Assign Lecture Teachers', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
