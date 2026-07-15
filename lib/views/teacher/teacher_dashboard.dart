import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/teacher/teacher_viewmodel.dart';
import '../../viewmodels/theme/theme_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/cards/lecture_card.dart';
import '../../widgets/common/shimmer_loader.dart';

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
                  colors: [Color(0xFF064E3B), Color(0xFF059669)],
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
                                    decoration: const BoxDecoration(color: Color(0xFFFBBF24), shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                          PopupMenuButton(
                            icon: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                (auth.currentUser?.firstName ?? 'T')[0].toUpperCase(),
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
                                  auth.currentUser?.firstName != null ? 'Prof. ${auth.currentUser!.firstName}' : 'Teacher',
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 4),
                                const Text('Teacher Portal', style: TextStyle(color: Colors.white54, fontSize: 13)),
                              ],
                            ),
                          ),
                          // Today's classes summary
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${vm.todayLectures.length}',
                                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                                ),
                                const Text('Classes\nToday', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Summary Row
                      if (vm.isLoadingDashboard)
                        const ShimmerLoader(height: 60)
                      else
                        Row(
                          children: [
                            _HeaderStat(label: 'Students', value: '${vm.classStudents.length}', color: Colors.white),
                            _HeaderStat(label: 'Pending', value: '${vm.todayLectures.where((l) => !l.attendanceTaken).length}', color: const Color(0xFFFBBF24)),
                            _HeaderStat(label: 'Alerts', value: '${vm.notifications.length}', color: Colors.white),
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
                // ── Quick Actions ──
                const SizedBox(height: 8),
                _SectionTitle(title: "Quick Actions", isDark: isDark),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _QuickTile(label: 'Attendance', icon: Icons.check_circle_outline_rounded, color: const Color(0xFF059669), isDark: isDark, onTap: () => context.push(AppConstants.routeTakeAttendance))),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickTile(label: 'My Students', icon: Icons.groups_rounded, color: const Color(0xFF2563EB), isDark: isDark, onTap: () => context.push(AppConstants.routeTeacherStudents))),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickTile(label: 'Enter Marks', icon: Icons.edit_note_rounded, color: const Color(0xFF7C3AED), isDark: isDark, onTap: () => context.push(AppConstants.routeMarksEntry))),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickTile(label: 'Homework', icon: Icons.assignment_rounded, color: const Color(0xFFF59E0B), isDark: isDark, onTap: () => context.push(AppConstants.routeHomeworkAdd))),
                  ],
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 28),

                // ── Today's Schedule ──
                _SectionTitle(title: "Today's Schedule", isDark: isDark),
                const SizedBox(height: 12),
                if (vm.isLoadingDashboard)
                  const ShimmerList(count: 2, itemHeight: 100)
                else if (vm.todayLectures.isEmpty)
                  _EmptyCard(message: 'No lectures scheduled for today', icon: Icons.calendar_today_rounded, isDark: isDark)
                else
                  ...vm.todayLectures.asMap().entries.map((e) => LectureCard(
                    lecture: e.value,
                    onAttendance: () => context.push(AppConstants.routeTakeAttendance),
                    onViewStudents: () {},
                  ).animate().fadeIn(delay: Duration(milliseconds: 80 + e.key * 60)).slideY(begin: 0.1, end: 0)),

                const SizedBox(height: 28),

                // ── Notifications ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionTitle(title: 'Notifications', isDark: isDark),
                    TextButton(onPressed: () => context.push(AppConstants.routeNotifications), child: const Text('See All', style: TextStyle(fontWeight: FontWeight.w700))),
                  ],
                ),
                const SizedBox(height: 8),
                if (vm.isLoadingDashboard)
                  const ShimmerList(count: 3, itemHeight: 70)
                else if (vm.notifications.isEmpty)
                  _EmptyCard(message: 'No notifications', icon: Icons.notifications_none_rounded, isDark: isDark)
                else
                  ...vm.notifications.take(4).map((n) => _NotifRow(
                    title: n.title,
                    subtitle: n.message,
                    isDark: isDark,
                    type: n.type,
                   )),

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
        indicatorColor: const Color(0xFF059669).withValues(alpha: 0.15),
        onDestinationSelected: (i) {
          setState(() => _navIndex = i);
          if (i == 1) context.push(AppConstants.routeTakeAttendance);
          if (i == 2) context.push(AppConstants.routeMarksEntry);
          if (i == 3) context.push(AppConstants.routeHomeworkAdd);
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.how_to_reg_rounded), label: 'Attendance'),
          const NavigationDestination(icon: Icon(Icons.grade_rounded), label: 'Marks'),
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

class _HeaderStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _HeaderStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : const Color(0xFF0F172A), letterSpacing: -0.3));
  }
}

class _QuickTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _QuickTile({required this.label, required this.icon, required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B27) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF334155))),
          ],
        ),
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final String title, subtitle, type;
  final bool isDark;
  const _NotifRow({required this.title, required this.subtitle, required this.isDark, required this.type});

  Color get _iconColor {
    switch (type) {
      case 'alert': return const Color(0xFFEF4444);
      case 'assignment': return const Color(0xFFF59E0B);
      case 'event': return const Color(0xFF10B981);
      default: return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: _iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.campaign_rounded, color: _iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
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
