import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../viewmodels/student/student_viewmodel.dart';

class StudentResultsScreen extends StatelessWidget {
  const StudentResultsScreen({super.key});

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+': return Colors.green;
      case 'A':  return Colors.teal;
      case 'B':  return Colors.blue;
      case 'C':  return Colors.orange;
      default:   return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentViewModel>();
    final cs = Theme.of(context).colorScheme;
    final results = vm.results;

    final totalObtained = results.fold<int>(0, (s, r) => s + (r['marks'] as int));
    final totalMax = results.fold<int>(0, (s, r) => s + (r['total'] as int));
    final overallPct = totalMax > 0 ? (totalObtained / totalMax) : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Results')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Overall card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                    blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 55,
                  lineWidth: 9,
                  percent: overallPct,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${(overallPct * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overall Score',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('$totalObtained / $totalMax',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Mid-Term Examination',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 24),
          Text('Subject-wise Results', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),

          ...results.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            final pct = (r['marks'] as int) / (r['total'] as int);
            final grade = r['grade'] as String;
            final color = _gradeColor(grade);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(grade,
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, color: color, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(r['subject'] as String,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700)),
                      ),
                      Text('${r['marks']} / ${r['total']}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16, color: color)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 100 + i * 80)).slideY(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }
}
