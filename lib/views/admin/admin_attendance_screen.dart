import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../core/utils/export_utils.dart';
import '../../widgets/buttons/custom_button.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Class Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) {
                setState(() => _selectedDate = d);
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Attendance for ${_selectedDate.toString().split(' ')[0]}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: vm.classes.length,
              itemBuilder: (ctx, i) {
                final c = vm.classes[i];
                final att = vm.getAttendanceForClass(c.id, _selectedDate);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(c.name),
                    subtitle: Text('Class Teacher: ${c.classTeacherName.isNotEmpty ? c.classTeacherName : 'Not Assigned'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${att.toStringAsFixed(1)}%', style: TextStyle(color: att >= 75 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.blue),
                          onPressed: () {
                            _showDownloadOptions(context, c.name, _selectedDate);
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showDownloadOptions(BuildContext context, String className, DateTime date) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Download as PDF'),
              onTap: () {
                Navigator.pop(context);
                ExportUtils.exportAttendanceToPdf(className, date, [{'rollNumber': 'N/A', 'name': 'Summary Report', 'status': 'Generated'}]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Download as Excel'),
              onTap: () {
                Navigator.pop(context);
                ExportUtils.exportAttendanceToExcel(className, date, [{'rollNumber': 'N/A', 'name': 'Summary Report', 'status': 'Generated'}]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
