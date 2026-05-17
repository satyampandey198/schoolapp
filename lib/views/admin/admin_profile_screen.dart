import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../widgets/buttons/custom_button.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  void _changePassword(BuildContext context, AuthViewModel auth) async {
    final newPass = _newPasswordCtrl.text.trim();
    if (newPass.isEmpty) return;

    setState(() => _isSaving = true);
    await Future.delayed(
        const Duration(seconds: 1)); // Simulate network request
    if (!mounted) return;

    // We assume the old password check passes for this mock
    auth.updatePassword(auth.currentUser!.id, newPass);
    setState(() => _isSaving = false);

    _oldPasswordCtrl.clear();
    _newPasswordCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;
    final cs = Theme.of(context).colorScheme;

    if (user == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withOpacity(0.1),
                ),
                child: Icon(Icons.shield_rounded, size: 50, color: cs.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text('Account Information',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _InfoRow(
                label: 'Name',
                value: '${user.firstName} ${user.lastName ?? ''}'),
            const Divider(),
            _InfoRow(label: 'Username', value: user.username),
            const Divider(),
            _InfoRow(label: 'Email', value: user.email ?? 'N/A'),
            const SizedBox(height: 32),
            Text('Change Password',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _oldPasswordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Update Password',
              onPressed: () => _changePassword(context, auth),
              isLoading: _isSaving,
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () {
                auth.logout();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
