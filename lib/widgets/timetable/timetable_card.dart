import 'package:flutter/material.dart';
import '../../models/lecture_model.dart';

class TimetableCard extends StatelessWidget {
  final TimetableEntry entry;

  const TimetableCard({super.key, required this.entry});

  Color _subjectColor(String subject) {
    final colors = {
      'Mathematics': Colors.blue,
      'English':     Colors.purple,
      'Science':     Colors.green,
      'Hindi':       Colors.orange,
      'History':     Colors.red,
    };
    return colors[subject] ?? Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _subjectColor(entry.subject);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.subject,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 13, color: cs.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(entry.time, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on_outlined, size: 13, color: cs.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(entry.room, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ],
            ),
          ),
          Text(entry.teacher,
              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
