import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Subjects')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      labelText: 'New Subject',
                      hintText: 'e.g. Computer Science',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (_) => _add(vm),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _add(vm),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: vm.globalSubjects.isEmpty
                ? Center(child: Text('No subjects yet.', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.globalSubjects.length,
                    itemBuilder: (_, i) {
                      final subject = vm.globalSubjects[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.book_rounded, color: cs.primary, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded, color: Colors.red),
                              onPressed: () => _confirmRemove(context, vm, subject),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: i * 40));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _add(AdminViewModel vm) {
    final s = _ctrl.text.trim();
    if (s.isEmpty) return;
    vm.addSubject(s);
    _ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$s" added!'), backgroundColor: Colors.green),
    );
  }

  void _confirmRemove(BuildContext context, AdminViewModel vm, String subject) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Subject'),
        content: Text('Remove "$subject" from the system?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); vm.removeSubject(subject); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
