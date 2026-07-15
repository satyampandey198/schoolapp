import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';
import '../../core/utils/export_utils.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/common/shimmer_loader.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherViewModel>();
    final cs = Theme.of(context).colorScheme;
    final total = vm.classStudents.length;
    final present = vm.presentCount;
    final pct = total > 0 ? (present / total * 100).toStringAsFixed(0) : '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              final records = vm.classStudents.map((s) => {'rollNumber': s.rollNumber, 'name': s.name, 'status': s.isPresent ? 'Present' : 'Absent'}).toList();
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: const Text('Export as PDF'),
                        onTap: () {
                          Navigator.pop(context);
                          ExportUtils.exportAttendanceToPdf('Class', vm.selectedAttendanceDate, records);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.table_chart, color: Colors.green),
                        title: const Text('Export as Excel'),
                        onTap: () {
                          Navigator.pop(context);
                          ExportUtils.exportAttendanceToExcel('Class', vm.selectedAttendanceDate, records);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (vm.currentAttendanceRecord?.isEdited == true)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: const Text('Edited', style: TextStyle(color: Colors.white, fontSize: 11)),
                backgroundColor: Colors.orange,
                padding: EdgeInsets.zero,
                onPressed: () => _showEditHistory(context, vm),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('$present/$total',
                  style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary, fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Date: ${vm.selectedAttendanceDate.toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: vm.selectedAttendanceDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) {
                if (context.mounted) context.read<TeacherViewModel>().changeAttendanceDate(d);
              }
            },
          ),
          // Summary bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text('$pct%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attendance Today', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('$present present • ${total - present} absent',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // Student list
          Expanded(
            child: vm.isLoadingDashboard
                ? const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: ShimmerList(count: 8, itemHeight: 65))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vm.classStudents.length,
              itemBuilder: (_, i) {
                final s = vm.classStudents[i];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: s.isPresent
                        ? Colors.green.withValues(alpha: 0.08)
                        : Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: s.isPresent
                          ? Colors.green.withValues(alpha: 0.35)
                          : Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: s.isPresent
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        child: Text(
                          s.name[0],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: s.isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(s.rollNumber,
                                style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55))),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: s.isPresent,
                        activeColor: Colors.green,
                        onChanged: (_) => context.read<TeacherViewModel>().toggleAttendance(s.id),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 30));
              },
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              label: vm.attendanceSaved ? '✓ Attendance Saved' : 'Save Attendance',
              onPressed: vm.attendanceSaved ? null : () async {
                try {
                  await context.read<TeacherViewModel>().saveAttendance();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance Saved!'), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
                  }
                }
              },
              color: vm.attendanceSaved ? Colors.green : null,
              icon: vm.attendanceSaved ? Icons.check_circle_rounded : Icons.save_rounded,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditHistory(BuildContext context, TeacherViewModel vm) {
    final record = vm.currentAttendanceRecord;
    if (record == null || !record.isEdited) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Edit History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Edited by: ${record.editedBy ?? "Unknown"}'),
              Text('Edited on: ${record.editedTimestamp.toString().split('.')[0]}'),
              const SizedBox(height: 24),
              const Text('Changes:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: record.records.entries.map((e) {
                    final studentId = e.key;
                    final currentStatus = e.value;
                    final originalStatus = record.originalRecords?[studentId];
                    if (originalStatus != null && originalStatus != currentStatus) {
                      final student = vm.classStudents.firstWhere((s) => s.id == studentId, orElse: () => vm.classStudents[0]);
                      return ListTile(
                        title: Text(student.name),
                        subtitle: Text('Changed from ${originalStatus ? 'Present' : 'Absent'} to ${currentStatus ? 'Present' : 'Absent'}'),
                        leading: const Icon(Icons.edit_note_rounded, color: Colors.orange),
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
