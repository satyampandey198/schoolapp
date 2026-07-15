import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/buttons/custom_button.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _imgCtrl = TextEditingController();
  bool _isSending = false;

  String _targetType = 'all_students';
  String _notificationType = 'info';
  String? _selectedTargetId;

  // For teachers: 'class', 'student'
  // For admins: 'all_teachers', 'all_students', 'class', 'teacher', 'student'

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send(BuildContext context, String role) async {
    final title = _titleCtrl.text.trim();
    final msg = _msgCtrl.text.trim();

    if (title.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter title and message')));
      return;
    }

    if ((_targetType == 'class' || _targetType == 'teacher' || _targetType == 'student') && _selectedTargetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a specific target')));
      return;
    }

    setState(() => _isSending = true);

    try {
      if (role == AppConstants.roleAdmin) {
        await context.read<AdminViewModel>().sendNotification(
          title, msg, _notificationType, 
          targetType: _targetType, 
          targetId: _selectedTargetId,
          imageUrl: _imgCtrl.text.trim().isNotEmpty ? _imgCtrl.text.trim() : null,
        );
      } else if (role == AppConstants.roleTeacher) {
        await context.read<TeacherViewModel>().sendNotification(
          title, msg, _notificationType,
          targetType: _targetType,
          targetId: _selectedTargetId,
          imageUrl: _imgCtrl.text.trim().isNotEmpty ? _imgCtrl.text.trim() : null,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent successfully!'), backgroundColor: Colors.green));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthViewModel>().role;
    
    // Admins need access to teachers, classes, students
    final adminVm = role == AppConstants.roleAdmin ? context.watch<AdminViewModel>() : null;
    // Teachers need access to their assigned class and students
    final teacherVm = role == AppConstants.roleTeacher ? context.watch<TeacherViewModel>() : null;

    List<DropdownMenuItem<String>> targetTypeOptions = [];
    if (role == AppConstants.roleAdmin) {
      targetTypeOptions = const [
        DropdownMenuItem(value: 'all_students', child: Text('All Students')),
        DropdownMenuItem(value: 'all_teachers', child: Text('All Teachers')),
        DropdownMenuItem(value: 'class', child: Text('Specific Class')),
        DropdownMenuItem(value: 'teacher', child: Text('Specific Teacher')),
        DropdownMenuItem(value: 'student', child: Text('Specific Student')),
      ];
    } else {
      targetTypeOptions = const [
        DropdownMenuItem(value: 'class', child: Text('Entire Class')),
        DropdownMenuItem(value: 'student', child: Text('Personal (Specific Student)')),
      ];
      // Default for teacher
      if (_targetType == 'all_students') _targetType = 'class';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _targetType,
              decoration: const InputDecoration(labelText: 'Target Audience'),
              items: targetTypeOptions,
              onChanged: (v) {
                setState(() {
                  _targetType = v!;
                  _selectedTargetId = null; // Reset selection
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Dynamic dropdown based on targetType
            if (_targetType == 'class' && role == AppConstants.roleAdmin)
              DropdownButtonFormField<String>(
                value: _selectedTargetId,
                decoration: const InputDecoration(labelText: 'Select Class'),
                items: adminVm?.classes.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name} - ${c.section}'))).toList(),
                onChanged: (v) => setState(() => _selectedTargetId = v),
              ),

            if (_targetType == 'class' && role == AppConstants.roleTeacher)
              // Since teachers are assigned to specific classes, maybe just default to their class, or list classes if they have multiple.
              // For simplicity, we can let them type or select if we add class tracking.
              // Let's assume they only have one class for now (handled implicitly on the backend or we just pass 'my_class' if it's 1-to-1).
              // Wait, in our TeacherViewModel, we have `classStudents`. So we know their class.
              DropdownButtonFormField<String>(
                value: _selectedTargetId,
                decoration: const InputDecoration(labelText: 'Select Class'),
                items: [const DropdownMenuItem(value: 'my_class', child: Text('My Assigned Class'))],
                onChanged: (v) => setState(() => _selectedTargetId = v),
              ),

            if (_targetType == 'teacher' && role == AppConstants.roleAdmin)
              DropdownButtonFormField<String>(
                value: _selectedTargetId,
                decoration: const InputDecoration(labelText: 'Select Teacher'),
                items: adminVm?.teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                onChanged: (v) => setState(() => _selectedTargetId = v),
              ),
              
            if (_targetType == 'student')
              DropdownButtonFormField<String>(
                value: _selectedTargetId,
                decoration: const InputDecoration(labelText: 'Select Student'),
                items: role == AppConstants.roleAdmin 
                  ? adminVm?.students.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.rollNumber})'))).toList()
                  : teacherVm?.classStudents.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.rollNumber})'))).toList(),
                onChanged: (v) => setState(() => _selectedTargetId = v),
              ),

            const SizedBox(height: 24),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _msgCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _notificationType,
              decoration: const InputDecoration(labelText: 'Notification Type'),
              items: const [
                DropdownMenuItem(value: 'info', child: Text('Information')),
                DropdownMenuItem(value: 'alert', child: Text('Alert / Emergency')),
                DropdownMenuItem(value: 'assignment', child: Text('Assignment')),
                DropdownMenuItem(value: 'event', child: Text('Event')),
              ],
              onChanged: (v) => setState(() => _notificationType = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imgCtrl,
              decoration: InputDecoration(
                labelText: 'Image URL (Optional)',
                hintText: 'https://...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Send Notification',
              onPressed: () => _send(context, role ?? 'student'),
              isLoading: _isSending,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
