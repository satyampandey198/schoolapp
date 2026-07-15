import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/student/student_viewmodel.dart';
import '../../viewmodels/theme/theme_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/shimmer_loader.dart';

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
    final theme = context.watch<ThemeViewModel>();
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F2F8),
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF4F46E5)],
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
                      // App Bar
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset('assets/images/App-logo.png', width: 30, height: 30),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.white70),
                            onPressed: () => context.read<ThemeViewModel>().toggle(),
                          ),
                          PopupMenuButton(
                            icon: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                (auth.currentUser?.firstName ?? 'S')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'account', child: Text('Manage Account')),
                              const PopupMenuItem(value: 'logout', child: Text('Logout')),
                            ],
                            onSelected: (v) {
                              if (v == 'account') context.push(AppConstants.routeManageAccount);
                              if (v == 'logout') {
                                context.read<AuthViewModel>().logout();
                                context.go(AppConstants.routeLogin);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Greeting
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Good ${_greeting()}, 👋', style: const TextStyle(color: Colors.white60, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  auth.currentUser?.firstName ?? 'Student',
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 4),
                                const Text('Student Portal', style: TextStyle(color: Colors.white54, fontSize: 13)),
                              ],
                            ),
                          ),
                          // Attendance Ring
                          CircularPercentIndicator(
                            radius: 46,
                            lineWidth: 7,
                            percent: (vm.attendancePercentage / 100).clamp(0.0, 1.0),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${vm.attendancePercentage.toStringAsFixed(0)}%',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                                ),
                                const Text('Attnd.', style: TextStyle(color: Colors.white60, fontSize: 9)),
                              ],
                            ),
                            progressColor: const Color(0xFFA5F3FC),
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
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
                const SizedBox(height: 8),

                // ── Quick Access Grid ──
                _SectionTitle(title: 'Quick Access', isDark: isDark),
                const SizedBox(height: 12),
                if (vm.isLoadingDashboard)
                  const ShimmerGrid(count: 4, crossAxisCount: 2, childAspectRatio: 1.6)
                else
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _MenuCard(
                        label: 'Timetable',
                        subtitle: '${vm.lectures.length} Periods',
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFF2563EB),
                        isDark: isDark,
                        onTap: () => context.push(AppConstants.routeStudentTimetable),
                      ),
                      _MenuCard(
                        label: 'Results',
                        subtitle: '${vm.results.length} Subjects',
                        icon: Icons.grade_rounded,
                        color: const Color(0xFF7C3AED),
                        isDark: isDark,
                        onTap: () => context.push(AppConstants.routeStudentResults),
                      ),
                      _MenuCard(
                        label: 'Homework',
                        subtitle: '${vm.pendingHomework} Pending',
                        icon: Icons.assignment_rounded,
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                        onTap: () => context.push(AppConstants.routeStudentHomework),
                      ),
                      _MenuCard(
                        label: 'Complaints',
                        subtitle: '${vm.complaints.length} Tickets',
                        icon: Icons.report_problem_rounded,
                        color: const Color(0xFF059669),
                        isDark: isDark,
                        onTap: () => context.push(AppConstants.routeStudentComplaints),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 28),

                // ── Homework Due ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionTitle(title: 'Homework Due', isDark: isDark),
                    TextButton(onPressed: () => context.push(AppConstants.routeStudentHomework), child: const Text('See All', style: TextStyle(fontWeight: FontWeight.w700))),
                  ],
                ),
                const SizedBox(height: 10),
                if (vm.isLoadingDashboard)
                  const ShimmerList(count: 2, itemHeight: 80)
                else if (vm.homework.isEmpty)
                  _EmptyCard(message: 'No pending homework', icon: Icons.check_circle_outline_rounded, isDark: isDark)
                else
                  ...vm.homework.take(3).toList().asMap().entries.map((entry) {
                    final hw = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B27) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.assignment_outlined, color: Color(0xFFF59E0B), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(hw.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(
                                  '${hw.subject} • Due ${hw.dueDate.day}/${hw.dueDate.month}',
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 200 + entry.key * 60));
                  }),

                const SizedBox(height: 28),

                // ── Notifications ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionTitle(title: 'Notifications', isDark: isDark),
                    TextButton(onPressed: () => context.push(AppConstants.routeNotifications), child: const Text('See All', style: TextStyle(fontWeight: FontWeight.w700))),
                  ],
                ),
                const SizedBox(height: 10),
                if (vm.isLoadingDashboard)
                  const ShimmerList(count: 3, itemHeight: 70)
                else if (vm.notifications.isEmpty)
                  _EmptyCard(message: 'No new notifications', icon: Icons.notifications_none_rounded, isDark: isDark)
                else
                  ...vm.notifications.take(4).map((n) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B27) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(color: const Color(0xFF4F46E5).withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.campaign_rounded, color: Color(0xFF4F46E5), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(n.message, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: 0.05, end: 0)),

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
        indicatorColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
        onDestinationSelected: (i) {
          setState(() => _navIndex = i);
          if (i == 1) context.push(AppConstants.routeStudentTimetable);
          if (i == 2) context.push(AppConstants.routeStudentResults);
          if (i == 3) context.push(AppConstants.routeNotifications);
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.schedule_rounded), label: 'Timetable'),
          const NavigationDestination(icon: Icon(Icons.grade_rounded), label: 'Results'),
          NavigationDestination(
            icon: Badge(isLabelVisible: vm.notifications.isNotEmpty, child: const Icon(Icons.notifications_rounded)),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w800,
      color: isDark ? Colors.white : const Color(0xFF0F172A),
      letterSpacing: -0.3,
    ));
  }
}

class _MenuCard extends StatelessWidget {
  final String label, subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;
  const _MenuCard({required this.label, required this.subtitle, required this.icon, required this.color, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B27) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark ? [] : [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.2 : 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isDark;
  const _EmptyCard({required this.message, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B27) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13)),
        ],
      ),
    );
  }
}
