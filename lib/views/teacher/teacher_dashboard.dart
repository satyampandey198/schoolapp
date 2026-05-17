import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';
import '../../viewmodels/theme/theme_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/cards/lecture_card.dart';
import '../../widgets/notifications/notification_tile.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<TeacherViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${auth.currentUser?.firstName ?? 'Teacher'} 👋',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Teacher Dashboard',
                style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(context.watch<ThemeViewModel>().isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => context.read<ThemeViewModel>().toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppConstants.routeNotifications),
          ),
          PopupMenuButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF7C3AED),
              child: Text('T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          // Summary row
          Row(
            children: [
              _SummaryChip(label: 'Classes Today', value: '${vm.todayLectures.length}', color: const Color(0xFF2563EB)),
              const SizedBox(width: 12),
              _SummaryChip(label: 'Pending Attendance', value: '${vm.todayLectures.where((l) => !l.attendanceTaken).length}', color: const Color(0xFFD97706)),
              const SizedBox(width: 12),
              _SummaryChip(label: 'Notifications', value: '${vm.notifications.length}', color: const Color(0xFF059669)),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),

          // Today's schedule
          Text("Today's Schedule", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          ...vm.todayLectures.asMap().entries.map((entry) {
            final i = entry.key;
            final lecture = entry.value;
            return LectureCard(
              lecture: lecture,
              onAttendance: () => context.push(AppConstants.routeTakeAttendance),
              onViewStudents: () {},
            ).animate().fadeIn(delay: Duration(milliseconds: 100 + i * 80)).slideY(begin: 0.1, end: 0);
          }),

          const SizedBox(height: 24),

          // Quick actions
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuickAction(label: 'Take Attendance', icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF059669), onTap: () => context.push(AppConstants.routeTakeAttendance)),
              const SizedBox(width: 12),
              _QuickAction(label: 'My Students', icon: Icons.groups_rounded,
                  color: const Color(0xFF2563EB), onTap: () => context.push(AppConstants.routeTeacherStudents)),
              const SizedBox(width: 12),
              _QuickAction(label: 'Enter Marks', icon: Icons.edit_note_rounded,
                  color: const Color(0xFF7C3AED), onTap: () => context.push(AppConstants.routeMarksEntry)),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Notifications
          Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...vm.notifications.map((n) => NotificationTile(notification: n)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) {
          setState(() => _navIndex = i);
          if (i == 1) context.push(AppConstants.routeTakeAttendance);
          if (i == 2) context.push(AppConstants.routeMarksEntry);
          if (i == 3) context.push(AppConstants.routeHomeworkAdd);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.how_to_reg_rounded), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.grade_rounded), label: 'Marks'),
          NavigationDestination(icon: Icon(Icons.assignment_rounded), label: 'Homework'),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
