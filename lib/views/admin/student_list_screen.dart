import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../models/student_model.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String _searchQuery = '';
  String _selectedClass = 'All';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final cs = Theme.of(context).colorScheme;

    // Get unique classes for filter
    final classesList = ['All', ...vm.classes.map((c) => '${c.name}-${c.section}')];
    if (!classesList.contains(_selectedClass)) _selectedClass = 'All';

    // Apply filters
    var filteredStudents = vm.students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            s.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      final clsStr = '${s.className}-${s.section}';
      final matchesClass = _selectedClass == 'All' || clsStr == _selectedClass;
      return matchesSearch && matchesClass;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => context.push(AppConstants.routeAddStudent),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.all(16),
            color: cs.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search name or roll no...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outline.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedClass,
                          items: classesList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _selectedClass = v!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Students: ${filteredStudents.length}', style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary)),
                    if (_selectedClass != 'All')
                      Text('Class: $_selectedClass', style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6))),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Student List
          Expanded(
            child: filteredStudents.isEmpty
                ? Center(child: Text('No students found', style: TextStyle(color: cs.onSurface.withOpacity(0.5))))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStudents.length,
                    itemBuilder: (_, i) => _StudentCard(
                      student: filteredStudents[i],
                      onDelete: () => vm.removeStudent(filteredStudents[i].id),
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 30)),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppConstants.routeAddStudent),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Student'),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onDelete;

  const _StudentCard({required this.student, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cs.primary.withOpacity(0.1),
            child: Text(student.name[0], style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text('Roll: ${student.rollNumber} | Class: ${student.className}-${student.section}',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'credentials', child: Text('View Credentials')),
              const PopupMenuItem(value: 'reset_pass', child: Text('Reset Password')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
            onSelected: (v) {
              if (v == 'edit') _showEditStudentDialog(context);
              if (v == 'credentials') _showCredentials(context);
              if (v == 'reset_pass') _showResetPassword(context);
              if (v == 'delete') onDelete();
            },
          )
        ],
      ),
    );
  }

  void _showCredentials(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Student Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${student.loginUsername}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Password: ${student.loginPassword}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Username: ${student.loginUsername}\nPassword: ${student.loginPassword}'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
            },
            child: const Text('Copy'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showResetPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'New Password', hintText: 'Enter new password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newPass = ctrl.text.trim();
              if (newPass.isNotEmpty) {
                context.read<AdminViewModel>().updateStudentPassword(student.id, newPass);
                // Also update in auth viewmodel mock
                context.read<AuthViewModel>().updatePassword(student.id, newPass);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated!')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: student.name);
    final rollCtrl = TextEditingController(text: student.rollNumber);
    final classCtrl = TextEditingController(text: student.className);
    final sectionCtrl = TextEditingController(text: student.section);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(controller: rollCtrl, decoration: const InputDecoration(labelText: 'Roll Number')),
              const SizedBox(height: 12),
              TextField(controller: classCtrl, decoration: const InputDecoration(labelText: 'Class')),
              const SizedBox(height: 12),
              TextField(controller: sectionCtrl, decoration: const InputDecoration(labelText: 'Section')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final updated = StudentModel(
                id: student.id,
                name: nameCtrl.text.trim(),
                rollNumber: rollCtrl.text.trim(),
                className: classCtrl.text.trim(),
                section: sectionCtrl.text.trim(),
                loginUsername: student.loginUsername,
                loginPassword: student.loginPassword,
              );
              context.read<AdminViewModel>().updateStudent(updated);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student updated successfully!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
