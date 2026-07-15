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
  bool _isLoading = false;

  void _generateCredentials() {
    if (_name.trim().isEmpty) return;
    setState(() {
      _generatedUsername = StudentModel.generateUsername(_name.trim());
      _generatedPassword = StudentModel.generatePassword(_name.trim());
    });
  }

  void _showDuplicateRollNumberDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Duplicate Roll Number'),
          ],
        ),
        content: const Text('The Roll Number you entered already exists. Please use a unique Roll Number.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Student Name', 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  onSaved: (v) => _name = v!,
                  onChanged: (v) {
                    _name = v;
                    if (_generatedUsername.isNotEmpty) _generateCredentials();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Roll Number (Manual Entry)', 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter roll number' : null,
                  onSaved: (v) => _rollNumber = v!,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _className,
                        decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                        onSaved: (v) => _className = v!,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _section,
                        decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
                        onSaved: (v) => _section = v!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Auto-generate credentials section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.key_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text('Login Credentials', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_generatedUsername.isEmpty)
                        const Text('Click the button to auto-generate credentials for this student.', style: TextStyle(fontSize: 13, color: Colors.grey))
                      else ...[
                        Text('Username: $_generatedUsername', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Password: $_generatedPassword', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          _formKey.currentState?.save();
                          _generateCredentials();
                        },
                        icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                        label: Text(_generatedUsername.isEmpty ? 'Generate Credentials' : 'Regenerate'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        label: 'Save Student',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (_generatedUsername.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please generate credentials first')));
                              return;
                            }
                            
                            setState(() => _isLoading = true);

                            final student = StudentModel(
                              id: 's_${DateTime.now().millisecondsSinceEpoch}',
                              name: _name,
                              rollNumber: _rollNumber,
                              className: _className,
                              section: _section,
                              loginUsername: _generatedUsername,
                              loginPassword: _generatedPassword,
                            );
                            
                            try {
                              bool hasAdmin = false;
                              try {
                                await context.read<AdminViewModel>().addStudent(student);
                                hasAdmin = true;
                              } catch (e) {
                                if (e is ProviderNotFoundException) {
                                  // Ignore, fallback to teacher
                                } else {
                                  rethrow;
                                }
                              }
                              
                              if (!hasAdmin) {
                                // For teacher fallback (not typical but keeping logic)
                                await context.read<TeacherViewModel>().addStudent(student);
                              }
                              
                              if (!mounted) return;
                              setState(() => _isLoading = false);
                              _showCredentialsDialog(context);
                            } catch (e) {
                              if (!mounted) return;
                              setState(() => _isLoading = false);
                              
                              if (e.toString().contains('Roll Number already exists')) {
                                _showDuplicateRollNumberDialog();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          }
                        },
                      ),
              ],
            ),
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
        title: const Text('Student Created Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please note down the login credentials for the student:'),
            const SizedBox(height: 16),
            Text('Username: $_generatedUsername', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Password: $_generatedPassword', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
