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
import '../../widgets/common/shimmer_loader.dart';
import '../../core/utils/db_seeder.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _navIndex = 0;
  bool _isSeeding = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<AdminViewModel>();
    final theme = context.watch<ThemeViewModel>();
    final size = MediaQuery.of(context).size;
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F8),
      body: CustomScrollView(
        slivers: [
          // ── Premium Gradient Header ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1F5E), Color(0xFF3B4FD8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    children: [
                      // App Bar Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset('assets/images/App-logo.png',
                                width: 32, height: 32, fit: BoxFit.contain),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              color: Colors.white70,
                            ),
                            onPressed: () => context.read<ThemeViewModel>().toggle(),
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
                                onPressed: () => context.push(AppConstants.routeNotifications),
                              ),
                              if (vm.notifications.isNotEmpty)
                                Positioned(
                                  top: 8, right: 8,
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFBBF24),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          PopupMenuButton(
                            icon: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                (auth.currentUser?.firstName ?? 'P')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.account_circle_rounded), title: Text('My Profile'))),
                              const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout_rounded), title: Text('Logout'))),
                            ],
                            onSelected: (v) {
                              if (v == 'profile') context.push(AppConstants.routeAdminProfile);
                              if (v == 'logout') {
                                context.read<AuthViewModel>().logout();
                                context.go(AppConstants.routeLogin);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Greeting Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good ${_greeting()}, 👋',
                                  style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  auth.currentUser?.firstName != null
                                      ? 'Principal ${auth.currentUser!.firstName}'
                                      : 'Principal',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Principal\'s Control Panel',
                                  style: TextStyle(color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${DateTime.now().day}',
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  _monthName(DateTime.now().month),
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Stats Cards ──
                const SizedBox(height: 8),
                if (vm.isLoadingDashboard)
                  const ShimmerGrid(crossAxisCount: 2, childAspectRatio: 1.6, count: 4)
                else
                  GridView.count(
                    crossAxisCount: size.width > 600 ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: size.width > 600 ? 1.5 : 1.55,
                    children: [
                      _StatCard(title: 'Teachers', value: '${vm.totalTeachers}', icon: Icons.school_rounded,
                          color: const Color(0xFF6366F1), onTap: () => context.push(AppConstants.routeTeacherList)),
                      _StatCard(title: 'Students', value: '${vm.totalStudents}', icon: Icons.groups_rounded,
                          color: const Color(0xFF0EA5E9), onTap: () => context.push(AppConstants.routeStudentList)),
                      _StatCard(title: 'Classes', value: '${vm.totalClasses}', icon: Icons.class_rounded,
                          color: const Color(0xFF10B981), onTap: () => context.push(AppConstants.routeManageClasses)),
                      const _StatCard(title: 'Attendance', value: '87%', icon: Icons.bar_chart_rounded,
                          color: Color(0xFFF59E0B)),
                    ],
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),

                const SizedBox(height: 28),

                // ── Attendance Chart ──
                _SectionHeader(title: 'Weekly Attendance', isDark: isDark),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B27) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark ? [] : [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      maxY: 100,
                      barGroups: _buildBarGroups(context),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                              if (v.toInt() >= days.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(days[v.toInt()],
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white38 : Colors.black38)),
                              );
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

                const SizedBox(height: 28),

                // ── Quick Actions ──
                _SectionHeader(title: 'Quick Actions', isDark: isDark),
                const SizedBox(height: 14),
                _buildQuickActions(context, isDark),

                const SizedBox(height: 28),

                // ── Recent Notifications ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionHeader(title: 'Recent Alerts', isDark: isDark),
                    TextButton(
                      onPressed: () => context.push(AppConstants.routeNotifications),
                      child: const Text('See All', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (vm.isLoadingDashboard)
                  const ShimmerList(count: 3, itemHeight: 70)
                else if (vm.notifications.isEmpty)
                  _EmptyState(message: 'No notifications yet', icon: Icons.notifications_none_rounded, isDark: isDark)
                else
                  ...vm.notifications.take(3).map((n) => _NotifCard(n: n, isDark: isDark)).toList(),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF161B27) : Colors.white,
        indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.15),
        onDestinationSelected: (i) {
          setState(() => _navIndex = i);
          if (i == 1) context.push(AppConstants.routeStudentList);
          if (i == 2) context.push(AppConstants.routeTeacherList);
          if (i == 3) context.push(AppConstants.routeNotifications);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.groups_rounded), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.school_rounded), label: 'Teachers'),
          NavigationDestination(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      {'label': 'Students', 'icon': Icons.groups_rounded, 'route': AppConstants.routeStudentList, 'color': const Color(0xFF0EA5E9)},
      {'label': 'Teachers', 'icon': Icons.school_rounded, 'route': AppConstants.routeTeacherList, 'color': const Color(0xFF6366F1)},
      {'label': 'Timetable', 'icon': Icons.schedule_rounded, 'route': AppConstants.routeAdminTimetable, 'color': const Color(0xFFF43F5E)},
      {'label': 'Exams', 'icon': Icons.assignment_rounded, 'route': AppConstants.routeAdminExams, 'color': const Color(0xFFC026D3)},
      {'label': 'Complaints', 'icon': Icons.report_problem_rounded, 'route': AppConstants.routeAdminComplaints, 'color': const Color(0xFFF59E0B)},
      {'label': 'Classes', 'icon': Icons.class_rounded, 'route': AppConstants.routeManageClasses, 'color': const Color(0xFF8B5CF6)},
      {'label': 'Attendance', 'icon': Icons.check_circle_outline_rounded, 'route': AppConstants.routeClassAttendance, 'color': const Color(0xFF10B981)},
      {'label': 'Notifications', 'icon': Icons.campaign_rounded, 'route': AppConstants.routeNotifications, 'color': const Color(0xFF64748B)},
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: actions.map((a) {
        final color = a['color'] as Color;
        return GestureDetector(
          onTap: () => context.push(a['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B27) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? [] : [
                BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(a['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  a['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0);
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
    final values = [75.0, 88.0, 82.0, 94.0, 79.0];
    return List.generate(5, (i) => BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: values[i],
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: Colors.grey.withValues(alpha: 0.08),
          ),
        ),
      ],
    ));
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeViewModel>().isDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B27) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark ? [] : [
            BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        letterSpacing: -0.3,
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final dynamic n;
  final bool isDark;
  const _NotifCard({required this.n, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B27) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF6366F1), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(n.message, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isDark;
  const _EmptyState({required this.message, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
      ),
    );
  }
}
