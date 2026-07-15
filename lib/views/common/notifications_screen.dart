import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/notifications/notification_tile.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final role = auth.role;
    final cs = Theme.of(context).colorScheme;

    // Fetch notifications from the appropriate viewmodel
    final notifications = context.watch<AdminViewModel>().notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark All Read')),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64,
                      color: cs.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text('No notifications',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final notification = notifications[i];
                return GestureDetector(
                  onTap: () {
                    if (role == AppConstants.roleAdmin || role == AppConstants.roleTeacher) {
                      _showReadReceiptsDialog(context, notification);
                    }
                  },
                  child: NotificationTile(
                    notification: notification,
                  ).animate().fadeIn(delay: Duration(milliseconds: i * 60)).slideX(begin: -0.1, end: 0),
                );
              },
            ),
      floatingActionButton: role == AppConstants.roleAdmin || role == AppConstants.roleTeacher
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppConstants.routeSendNotification),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send Notification'),
            )
          : null,
    );
  }



  void _showReadReceiptsDialog(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Read By'),
        content: SizedBox(
          width: double.maxFinite,
          child: notification.readBy.isEmpty
              ? const Text('No one has read this notification yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notification.readBy.length,
                  itemBuilder: (ctx, idx) {
                    final userId = notification.readBy.keys.elementAt(idx);
                    final userName = notification.readBy[userId];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(userName ?? 'Unknown User'),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
