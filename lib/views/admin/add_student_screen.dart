import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';
import '../../models/student_model.dart';
import '../../widgets/buttons/custom_button.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _rollNumber = '';
  String _className = 'Class 10';
  String _section = 'A';

  // Auto-generated credentials
  String _generatedUsername = '';
  String _generatedPassword = '';

  void _generateCredentials() {
    if (_name.trim().isEmpty) return;
    setState(() {
      _generatedUsername = StudentModel.generateUsername(_name.trim());
      _generatedPassword = StudentModel.generatePassword(_name.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Student Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
                onSaved: (v) => _name = v!,
                onChanged: (v) {
                  _name = v;
                  if (_generatedUsername.isNotEmpty) _generateCredentials();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Roll Number', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter roll number' : null,
                onSaved: (v) => _rollNumber = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _className,
                decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                onSaved: (v) => _className = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _section,
                decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
                onSaved: (v) => _section = v!,
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
                      const Text('Click the button to auto-generate credentials for this student.', style: TextStyle(fontSize: 12, color: Colors.grey))
                    else ...[
                      Text('Username: $_generatedUsername', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Password: $_generatedPassword', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        _formKey.currentState?.save(); // save name
                        _generateCredentials();
                      },
                      icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                      label: Text(_generatedUsername.isEmpty ? 'Generate Credentials' : 'Regenerate'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              CustomButton(
                label: 'Save Student',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (_generatedUsername.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please generate credentials first')));
                      return;
                    }
                    final student = StudentModel(
                      id: 's_${DateTime.now().millisecondsSinceEpoch}',
                      name: _name,
                      rollNumber: _rollNumber,
                      className: _className,
                      section: _section,
                      loginUsername: _generatedUsername,
                      loginPassword: _generatedPassword,
                    );
                    // Check if Admin or Teacher is adding
                    try {
                      context.read<AdminViewModel>().addStudent(student);
                    } catch (_) {}
                    try {
                      context.read<TeacherViewModel>().addStudent(student);
                    } catch (_) {}
                    
                    _showCredentialsDialog(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCredentialsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Student Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: $_generatedUsername', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Password: $_generatedPassword', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
