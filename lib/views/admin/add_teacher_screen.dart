import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../models/teacher_model.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/inputs/custom_text_field.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _subject = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _exp = TextEditingController();
  final _qual = TextEditingController();

  // Auto-generated credentials
  String _generatedUsername = '';
  String _generatedPassword = '';
  bool _credentialsVisible = false;
  bool _isSaving = false;

  void _generateCredentials() {
    if (_name.text.trim().isEmpty) return;
    setState(() {
      _generatedUsername = TeacherModel.generateUsername(_name.text.trim());
      _generatedPassword = TeacherModel.generatePassword(_name.text.trim());
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_generatedUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate credentials first'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final vm = context.read<AdminViewModel>();
    try {
      await vm.addTeacher(TeacherModel(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        name: _name.text.trim(),
        subject: _subject.text.trim(),
        assignedClass: '',
        experience: '${_exp.text.trim()} Years',
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        qualification: _qual.text.trim(),
        loginUsername: _generatedUsername,
        loginPassword: _generatedPassword,
      ));
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showCredentialsDialog(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  void _showCredentialsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.key_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('Teacher Credentials'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share these login credentials with the teacher:', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            _CredBox(label: 'Username', value: _generatedUsername),
            const SizedBox(height: 8),
            _CredBox(label: 'Password', value: _generatedPassword),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Username: $_generatedUsername\nPassword: $_generatedPassword'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
            },
            child: const Text('Copy All'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose(); _subject.dispose(); _email.dispose();
    _phone.dispose(); _exp.dispose(); _qual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Teacher')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar preview
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
                  ),
                  child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _name, label: 'Full Name', hint: 'e.g. Rajesh Kumar',
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                onChanged: (_) { if (_generatedUsername.isNotEmpty) _generateCredentials(); },
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _subject, label: 'Subject', hint: 'e.g. Mathematics',
                prefixIcon: Icons.book_outlined,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _email, label: 'Email', hint: 'teacher@school.edu',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _phone, label: 'Phone', hint: '+91 98765 43210',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _exp, label: 'Experience (Years)', hint: 'e.g. 5',
                prefixIcon: Icons.work_outline_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _qual, label: 'Qualification', hint: 'e.g. M.Sc. Mathematics',
                prefixIcon: Icons.school_outlined,
              ),
              const SizedBox(height: 24),

              // Auto-generate credentials section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.key_rounded, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Text('Login Credentials', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_generatedUsername.isEmpty)
                      const Text('Click the button to auto-generate credentials for this teacher.', style: TextStyle(fontSize: 12, color: Colors.grey))
                    else ...[
                      _CredBox(label: 'Username', value: _generatedUsername),
                      const SizedBox(height: 8),
                      _CredBox(label: 'Password', value: _generatedPassword),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _generateCredentials,
                      icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                      label: Text(_generatedUsername.isEmpty ? 'Generate Credentials' : 'Regenerate'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.amber),
                        foregroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(label: 'Save Teacher', onPressed: _save, isLoading: _isSaving, icon: Icons.save_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _CredBox extends StatefulWidget {
  final String label, value;
  const _CredBox({required this.label, required this.value});

  @override
  State<_CredBox> createState() => _CredBoxState();
}

class _CredBoxState extends State<_CredBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                Text(widget.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.value));
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
