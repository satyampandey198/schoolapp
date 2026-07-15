import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';
import '../../models/student_model.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherViewModel>();
    final cs = Theme.of(context).colorScheme;

    final filteredStudents = vm.classStudents.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(query) || s.rollNumber.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Students')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name or roll number...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
          ),
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text('No students found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredStudents.length,
                    itemBuilder: (ctx, i) {
                      final s = filteredStudents[i];
                      final avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(s.name)}&background=random';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: cs.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                          border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'avatar_${s.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: avatarUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: cs.primaryContainer,
                                    child: Center(child: Text(s.name[0], style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold))),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: cs.primaryContainer,
                                    child: const Icon(Icons.person, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('${s.className} - ${s.section} • Roll: ${s.rollNumber}',
                                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              onPressed: () {
                                _showStudentInfo(context, s, avatarUrl);
                              },
                            )
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: i * 40)).slideX(begin: 0.05);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showStudentInfo(BuildContext context, StudentModel s, String avatarUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Hero(
                    tag: 'avatar_${s.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        width: 80, height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey.shade200),
                        errorWidget: (context, url, error) => const Icon(Icons.person, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Roll Number: ${s.rollNumber}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        Text('Class: ${s.className} - ${s.section}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Performance Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard('Attendance', '85%', Icons.check_circle_outline, Colors.green),
                  const SizedBox(width: 12),
                  _buildStatCard('Average Marks', '78%', Icons.bar_chart_rounded, Colors.blue),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard('Assignments', '12/15', Icons.assignment_turned_in, Colors.purple),
                  const SizedBox(width: 12),
                  _buildStatCard('Rank', '5th', Icons.emoji_events_rounded, Colors.orange),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Profile'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}
