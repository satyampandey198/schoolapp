import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../widgets/buttons/custom_button.dart';

class SendTimetableScreen extends StatefulWidget {
  const SendTimetableScreen({super.key});

  @override
  State<SendTimetableScreen> createState() => _SendTimetableScreenState();
}

class _SendTimetableScreenState extends State<SendTimetableScreen> {
  String? _selectedClassId;
  String _fileUrl = 'timetable_document.pdf';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Send Timetable')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Class to send Timetable to:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Select Class'),
              value: _selectedClassId,
              items: vm.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedClassId = v),
            ),
            const SizedBox(height: 24),
            const Text('Timetable Document (Mock Upload):', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(_fileUrl),
                ],
              ),
            ),
            const Spacer(),
            CustomButton(
              label: 'Send to Teachers & Students',
              onPressed: _selectedClassId == null ? null : () async {
                await context.read<AdminViewModel>().sendTimetable(_selectedClassId!, _fileUrl);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timetable sent successfully!')));
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
