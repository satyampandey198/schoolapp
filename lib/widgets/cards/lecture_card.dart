import 'package:flutter/material.dart';
import '../../models/lecture_model.dart';

class LectureCard extends StatelessWidget {
  final LectureModel lecture;
  final VoidCallback? onAttendance;
  final VoidCallback? onViewStudents;

  const LectureCard({
    super.key,
    required this.lecture,
    this.onAttendance,
    this.onViewStudents,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lecture.className,
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              if (lecture.attendanceTaken)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✓ Done',
                    style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lecture.subject,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text(
                '${lecture.startTime} – ${lecture.endTime}',
                style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 14),
              Icon(Icons.people_outline_rounded, size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text(
                '${lecture.totalStudents} Students',
                style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
          if (lecture.room.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text(lecture.room, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewStudents,
                  icon: const Icon(Icons.people_outline_rounded, size: 16),
                  label: const Text('View Students'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAttendance,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: const Text('Attendance'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
