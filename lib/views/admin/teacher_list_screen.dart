import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../models/teacher_model.dart';

class TeacherListScreen extends StatelessWidget {
  const TeacherListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(AppConstants.routeAddTeacher),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: vm.setSearch,
              decoration: InputDecoration(
                hintText: 'Search teachers…',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          Expanded(
            child: vm.teachers.isEmpty
                ? const Center(child: Text('No teachers found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.teachers.length,
                    itemBuilder: (_, i) => _TeacherCard(
                      teacher: vm.teachers[i],
                      onDelete: () => vm.removeTeacher(vm.teachers[i].id),
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 60)).slideX(begin: -0.1, end: 0),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppConstants.routeAddTeacher),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Teacher'),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  final VoidCallback onDelete;
  const _TeacherCard({required this.teacher, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = [
      const Color(0xFF2563EB), const Color(0xFF7C3AED), const Color(0xFF059669),
      const Color(0xFFD97706), const Color(0xFFEF4444),
    ];
    final color = colors[teacher.id.hashCode % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                teacher.name[0],
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(teacher.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(teacher.subject,
                    style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('${teacher.assignedClass} • ${teacher.experience}',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55))),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: cs.onSurface.withValues(alpha: 0.5)),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'credentials', child: Text('View Credentials')),
              const PopupMenuItem(value: 'reset_pass', child: Text('Reset Password')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
            onSelected: (v) {
              if (v == 'delete') {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Remove Teacher'),
                    content: Text('Remove ${teacher.name} from the system?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () { Navigator.pop(context); onDelete(); },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              } else if (v == 'credentials') {
                _showCredentialsDialog(context, teacher);
              } else if (v == 'reset_pass') {
                _showResetPasswordDialog(context, teacher);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCredentialsDialog(BuildContext context, TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [Icon(Icons.key_rounded, color: Colors.amber), SizedBox(width: 8), Text('Teacher Credentials')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CredRow(label: 'Username', value: teacher.loginUsername),
            const SizedBox(height: 8),
            _CredRow(label: 'Password', value: teacher.loginPassword),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Username: ${teacher.loginUsername}\nPassword: ${teacher.loginPassword}'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
            },
            child: const Text('Copy'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, TeacherModel teacher) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Teacher Password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password', hintText: 'Enter new password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newPass = ctrl.text.trim();
              if (newPass.isNotEmpty) {
                context.read<AdminViewModel>().updateTeacherPassword(teacher.id, newPass);
                context.read<AuthViewModel>().updatePassword(teacher.id, newPass);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _CredRow extends StatelessWidget {
  final String label, value;
  const _CredRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 16),
          onPressed: () => Clipboard.setData(ClipboardData(text: value)),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
