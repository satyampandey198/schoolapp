import 'package:flutter/material.dart';
import '../services/session_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;


  Widget _buildBentoCard({
    required String title,
    required String emoji,
    required String pillText,
    required Color pillColor,
    required Color pillTextColor,
    required Color backgroundColor,
    VoidCallback? onTap,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // We align everything properly
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  pillText,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: pillTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Morning,',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.0,
                            color: Colors.white),
                      ),
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.pinkAccent, Colors.cyanAccent],
                            ).createShader(bounds),
                            child: Text(
                              SessionManager().currentUser?.firstName ?? 'Student',
                              style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                  height: 1.1,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('👋', style: TextStyle(fontSize: 28)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14151C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        SessionManager().currentUser?.roleLabel ?? 'Student',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        SessionManager().currentUser?.username ?? '',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            
            // Bento Grid - Row 1
            Row(
              children: [
                Expanded(
                  child: _buildBentoCard(
                    title: 'Announcements',
                    emoji: '📢',
                    pillText: '4 new',
                    pillColor: Colors.cyan.withValues(alpha: 0.15),
                    pillTextColor: Colors.cyanAccent,
                    backgroundColor: const Color(0xFF1B2236),
                    onTap: () => Navigator.pushNamed(context, '/announcements'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBentoCard(
                    title: 'Attendance',
                    emoji: '📅',
                    pillText: '85% present',
                    pillColor: Colors.cyan.withValues(alpha: 0.15),
                    pillTextColor: Colors.cyanAccent,
                    backgroundColor: const Color(0xFF182033),
                    onTap: () => Navigator.pushNamed(context, '/attendance'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Bento Grid - Row 2
            _buildBentoCard(
              title: 'Profile',
              emoji: '⚡',
              pillText: 'Satyam Doe',
              pillColor: Colors.purpleAccent.withValues(alpha: 0.2),
              pillTextColor: Colors.purpleAccent.shade100,
              backgroundColor: const Color(0xFF23023F),
              onTap: () => Navigator.pushNamed(context, '/profile'),
              fullWidth: true,
            ),
            const SizedBox(height: 16),
            
            // Bento Grid - Row 3
            Row(
              children: [
                Expanded(
                  child: _buildBentoCard(
                    title: 'Homework',
                    // Fallback to library/books emoji since no brown book available
                    emoji: '📚', 
                    pillText: '2 pending',
                    pillColor: Colors.amber.withValues(alpha: 0.2),
                    pillTextColor: Colors.amber,
                    backgroundColor: const Color(0xFF281403),
                    onTap: () => Navigator.pushNamed(context, '/homework'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBentoCard(
                    title: 'Notifications',
                    emoji: '🔔',
                    pillText: '2 unread',
                    pillColor: Colors.greenAccent.withValues(alpha: 0.2),
                    pillTextColor: Colors.greenAccent,
                    backgroundColor: const Color(0xFF031E07),
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bento Grid - Row 4
            _buildBentoCard(
              title: 'Academic Results',
              emoji: '🏆',
              pillText: '1 new',
              pillColor: Colors.purpleAccent.withValues(alpha: 0.2),
              pillTextColor: Colors.purpleAccent.shade100,
              backgroundColor: const Color(0xFF33145E),
              onTap: () => Navigator.pushNamed(context, '/results'),
              fullWidth: true,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
           splashColor: Colors.transparent,
           highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0D0E15),
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white30,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          ],
        ),
      )
    );
  }
}
