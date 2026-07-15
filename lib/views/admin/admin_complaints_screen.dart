import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../models/complaint_model.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  String _filter = 'all'; // all, student, teacher

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    
    final filteredComplaints = vm.complaints.where((c) {
      if (_filter == 'all') return true;
      return c.submitterRole == _filter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Students', 'student'),
                const SizedBox(width: 8),
                _buildFilterChip('Teachers', 'teacher'),
              ],
            ),
          ),
        ),
      ),
      body: filteredComplaints.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('No complaints found.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredComplaints.length,
              itemBuilder: (context, index) {
                final complaint = filteredComplaints[index];
                return _buildComplaintCard(context, vm, complaint);
              },
            ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    final color = Theme.of(context).colorScheme.primary;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : null)),
      selected: isSelected,
      selectedColor: color,
      onSelected: (selected) {
        if (selected) setState(() => _filter = value);
      },
    );
  }

  Widget _buildComplaintCard(BuildContext context, AdminViewModel vm, ComplaintModel complaint) {
    final isResolved = complaint.status == 'resolved';
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: complaint.submitterRole == 'teacher' 
                        ? Colors.blue.withValues(alpha: 0.1) 
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    complaint.submitterRole.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: complaint.submitterRole == 'teacher' ? Colors.blue : Colors.orange,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isResolved ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    complaint.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isResolved ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(complaint.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              'By ${complaint.submitterName} • ${DateFormat('MMM d, yyyy h:mm a').format(complaint.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(complaint.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            
            if (complaint.adminReply != null && complaint.adminReply!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Admin Reply:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(complaint.adminReply!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (!isResolved)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _showReplyDialog(context, vm, complaint),
                    child: const Text('Reply'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () => vm.updateComplaintStatus(complaint.id, 'resolved'),
                    child: const Text('Mark Resolved'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(BuildContext context, AdminViewModel vm, ComplaintModel complaint) {
    final tc = TextEditingController(text: complaint.adminReply);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reply to Complaint'),
        content: TextField(
          controller: tc,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your reply...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              vm.updateComplaintStatus(complaint.id, complaint.status, reply: tc.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }
}
