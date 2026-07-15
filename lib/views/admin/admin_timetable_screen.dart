import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../models/lecture_schedule_model.dart';
import '../../models/class_model.dart';
import '../../models/teacher_model.dart';

class AdminTimetableScreen extends StatefulWidget {
  const AdminTimetableScreen({super.key});

  @override
  State<AdminTimetableScreen> createState() => _AdminTimetableScreenState();
}

class _AdminTimetableScreenState extends State<AdminTimetableScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    
    // Filter lectures by selected date
    final dailyLectures = vm.lectures.where((l) {
      return l.date.year == _selectedDate.year &&
             l.date.month == _selectedDate.month &&
             l.date.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Timetable'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_rounded),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
      body: dailyLectures.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('No lectures scheduled for this date.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dailyLectures.length,
              itemBuilder: (context, index) {
                final lecture = dailyLectures[index];
                return _buildLectureCard(context, vm, lecture);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLectureSheet(context, vm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Schedule Lecture'),
      ),
    );
  }

  Widget _buildLectureCard(BuildContext context, AdminViewModel vm, LectureScheduleModel lecture) {
    Color statusColor;
    switch (lecture.status) {
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(lecture.startTime, style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 13)),
              const Text('to', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(lecture.endTime, style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 13)),
            ],
          ),
        ),
        title: Text('${lecture.subject} - ${lecture.className}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(lecture.teacherName, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(lecture.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
              )
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              vm.deleteLecture(lecture.id);
            } else {
              vm.updateLectureStatus(lecture.id, value);
            }
          },
          itemBuilder: (context) => [
            if (lecture.status != 'completed') const PopupMenuItem(value: 'completed', child: Text('Mark Completed')),
            if (lecture.status != 'cancelled') const PopupMenuItem(value: 'cancelled', child: Text('Cancel Lecture', style: TextStyle(color: Colors.red))),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'delete', child: Text('Delete completely')),
          ],
        ),
      ),
    );
  }

  void _showAddLectureSheet(BuildContext context, AdminViewModel vm) {
    if (vm.classes.isEmpty || vm.teachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add classes and teachers first.')));
      return;
    }

    ClassModel? selectedClass = vm.classes.first;
    TeacherModel? selectedTeacher = vm.teachers.first;
    String subject = vm.globalSubjects.isNotEmpty ? vm.globalSubjects.first : '';
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Schedule New Lecture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<ClassModel>(
                      decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                      value: selectedClass,
                      items: vm.classes.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                      onChanged: (v) => setModalState(() => selectedClass = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TeacherModel>(
                      decoration: const InputDecoration(labelText: 'Teacher', border: OutlineInputBorder()),
                      value: selectedTeacher,
                      items: vm.teachers.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                      onChanged: (v) => setModalState(() => selectedTeacher = v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                      initialValue: subject,
                      onChanged: (v) => subject = v,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final t = await showTimePicker(context: context, initialTime: startTime);
                              if (t != null) setModalState(() => startTime = t);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Start Time', border: OutlineInputBorder()),
                              child: Text(startTime.format(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final t = await showTimePicker(context: context, initialTime: endTime);
                              if (t != null) setModalState(() => endTime = t);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'End Time', border: OutlineInputBorder()),
                              child: Text(endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (selectedClass != null && selectedTeacher != null && subject.isNotEmpty) {
                          final lecture = LectureScheduleModel(
                            id: '',
                            classId: selectedClass!.id,
                            className: selectedClass!.name,
                            teacherId: selectedTeacher!.id,
                            teacherName: selectedTeacher!.name,
                            subject: subject,
                            date: _selectedDate,
                            startTime: startTime.format(context),
                            endTime: endTime.format(context),
                            status: 'upcoming',
                          );
                          vm.addLecture(lecture);
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Schedule'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
