import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  Color _typeColor(String type) {
    switch (type) {
      case 'warning': return Colors.amber;
      case 'success': return Colors.green;
      case 'alert':   return Colors.red;
      default:        return Colors.blue;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'warning': return Icons.warning_amber_rounded;
      case 'success': return Icons.check_circle_outline_rounded;
      case 'alert':   return Icons.error_outline_rounded;
      default:        return Icons.info_outline_rounded;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _typeColor(notification.type);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? cs.surface : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead ? cs.outline.withValues(alpha: 0.3) : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_typeIcon(notification.type), color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(notification.message,
                      style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(_timeAgo(notification.createdAt),
                style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45))),
          ],
        ),
      ),
    );
  }
}
