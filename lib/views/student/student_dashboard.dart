import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/student/student_viewmodel.dart';
import '../../viewmodels/theme/theme_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/notifications/notification_tile.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<StudentViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${auth.currentUser?.firstName ?? 'Student'} 👋',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Class 10 – Section A',
                style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(context.watch<ThemeViewModel>().isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () => context.read<ThemeViewModel>().toggle(),
          ),
          PopupMenuButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF059669),
              child: Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            itemBuilder: (_) => [const PopupMenuItem(value: 'logout', child: Text('Logout'))],
            onSelected: (_) {
              context.read<AuthViewModel>().logout();
              context.go(AppConstants.routeLogin);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Attendance card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 50,
                  lineWidth: 8,
                  percent: vm.attendancePercentage / 100,
                  center: Text(
                    '${vm.attendancePercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Attendance',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text('Great progress!',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('87 / 100 Days Present',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Quick access grid
          Text('Quick Access', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _QuickCard(label: 'Timetable', icon: Icons.schedule_rounded,
                  color: const Color(0xFF2563EB),
                  count: '${vm.timetable.length} Periods',
                  onTap: () => context.push(AppConstants.routeStudentTimetable)),
              _QuickCard(label: 'Results', icon: Icons.grade_rounded,
                  color: const Color(0xFF7C3AED),
                  count: '5 Subjects',
                  onTap: () => context.push(AppConstants.routeStudentResults)),
              _QuickCard(label: 'Homework', icon: Icons.assignment_rounded,
                  color: const Color(0xFFD97706),
                  count: '${vm.pendingHomework} Pending'),
              _QuickCard(label: 'Notifications', icon: Icons.notifications_rounded,
                  color: const Color(0xFF059669),
                  count: '${vm.notifications.length} New',
                  onTap: () => context.push(AppConstants.routeNotifications)),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          // Homework due
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Homework Due", style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 10),
          ...vm.homework.asMap().entries.map((entry) {
            final i = entry.key;
            final hw = entry.value;
            final isDone = hw['status'] == 'submitted';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDone ? Icons.check_circle_rounded : Icons.assignment_outlined,
                      color: isDone ? Colors.green : Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hw['title']!,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('${hw['subject']} • Due ${hw['due']}',
                            style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(isDone ? 'Submitted' : 'Pending',
                        style: TextStyle(
                            fontSize: 11, color: isDone ? Colors.green : Colors.orange)),
                    backgroundColor: isDone
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    side: BorderSide(color: isDone
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3)),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 200 + i * 60));
          }),

          const SizedBox(height: 24),

          // Notifications
          Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...vm.notifications.map((n) => NotificationTile(notification: n)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) {
          setState(() => _navIndex = i);
          if (i == 1) context.push(AppConstants.routeStudentTimetable);
          if (i == 2) context.push(AppConstants.routeStudentResults);
          if (i == 3) context.push(AppConstants.routeNotifications);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.schedule_rounded), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.grade_rounded), label: 'Results'),
          NavigationDestination(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String label, count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _QuickCard({required this.label, required this.icon, required this.color, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
            Text(count, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
