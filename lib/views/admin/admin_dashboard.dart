import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/theme/theme_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/notifications/notification_tile.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<AdminViewModel>();
    final theme = context.watch<ThemeViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${auth.currentUser?.firstName ?? 'Admin'} 👋',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Administrator Dashboard',
                style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => context.read<ThemeViewModel>().toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppConstants.routeNotifications),
          ),
          PopupMenuButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF2563EB),
              child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.account_circle_rounded), title: Text('My Profile'))),
              const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout_rounded), title: Text('Logout'))),
            ],
            onSelected: (v) {
              if (v == 'profile') {
                context.push(AppConstants.routeAdminProfile);
              } else if (v == 'logout') {
                context.read<AuthViewModel>().logout();
                context.go(AppConstants.routeLogin);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Stats grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.2,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              if (index == 0) {
                return StatCard(
                  title: 'Total Teachers',
                  value: '${vm.totalTeachers}',
                  icon: Icons.school_rounded,
                  gradient: AppColors.blueGradient,
                  onTap: () => context.push(AppConstants.routeTeacherList),
                );
              }
              if (index == 1) {
                return StatCard(
                  title: 'Total Students',
                  value: '${vm.totalStudents}',
                  icon: Icons.people_rounded,
                  gradient: AppColors.purpleGradient,
                );
              }
              if (index == 2) {
                return StatCard(
                  title: 'Total Classes',
                  value: '${vm.totalClasses}',
                  icon: Icons.class_rounded,
                  gradient: AppColors.greenGradient,
                  onTap: () => context.push(AppConstants.routeManageClasses),
                );
              }
              return const StatCard(
                title: 'Attendance',
                value: '87%',
                icon: Icons.bar_chart_rounded,
                gradient: AppColors.orangeGradient,
              );
            },
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),


          const SizedBox(height: 24),

          // Quick actions
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _buildQuickActions(context),

          const SizedBox(height: 24),

          // Attendance chart
          Text('Attendance Overview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Container(
            height: 200,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
            ),
            child: BarChart(
              BarChartData(
                barGroups: _buildBarGroups(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                        return Text(days[v.toInt()], style: const TextStyle(fontSize: 11));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Notifications', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => context.push(AppConstants.routeNotifications),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...vm.notifications.map((n) => NotificationTile(notification: n)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) {
          setState(() => _navIndex = i);
          if (i == 1) context.push(AppConstants.routeTeacherList);
          if (i == 2) context.push(AppConstants.routeManageClasses);
          if (i == 3) context.push(AppConstants.routeNotifications);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_rounded), label: 'Teachers'),
          NavigationDestination(icon: Icon(Icons.class_rounded), label: 'Classes'),
          NavigationDestination(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'label': 'Manage Students', 'icon': Icons.groups_rounded, 'route': AppConstants.routeStudentList, 'color': const Color(0xFF059669)},
      {'label': 'Manage Classes', 'icon': Icons.class_rounded, 'route': AppConstants.routeManageClasses, 'color': const Color(0xFF2563EB)},
      {'label': 'Manage Subjects', 'icon': Icons.book_rounded, 'route': AppConstants.routeManageSubjects, 'color': const Color(0xFF7C3AED)},
      {'label': 'Teachers List', 'icon': Icons.list_rounded, 'route': AppConstants.routeTeacherList, 'color': const Color(0xFF059669)},
    ];
    return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final a = actions[index];
        return GestureDetector(
          onTap: () => context.push(a['route'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: (a['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: (a['color'] as Color).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(a['icon'] as IconData, color: a['color'] as Color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(a['label'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: a['color'] as Color)),
                ),
              ],
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 100.ms);
  }

  List<BarChartGroupData> _buildBarGroups() {
    final values = [82.0, 88.0, 79.0, 91.0, 85.0];
    return List.generate(5, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
    });
  }
}
