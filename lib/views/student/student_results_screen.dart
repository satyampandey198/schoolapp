import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/student/student_viewmodel.dart';
import '../../widgets/common/shimmer_loader.dart';

class StudentResultsScreen extends StatefulWidget {
  const StudentResultsScreen({super.key});

  @override
  State<StudentResultsScreen> createState() => _StudentResultsScreenState();
}

class _StudentResultsScreenState extends State<StudentResultsScreen> {
  String? _selectedExamType;

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
    
    // Extract unique exam types
    final examTypes = vm.results.map((r) => r.examType).toSet().toList();
    if (examTypes.isNotEmpty && (_selectedExamType == null || !examTypes.contains(_selectedExamType))) {
      _selectedExamType = examTypes.first;
    }

    // Filter results by selected exam type
    final filteredResults = vm.results.where((r) => r.examType == _selectedExamType).toList();

    final totalObtained = filteredResults.fold<int>(0, (s, r) => s + r.marks);
    final totalMax = filteredResults.fold<int>(0, (s, r) => s + r.totalMarks);
    final overallPct = totalMax > 0 ? (totalObtained / totalMax) : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Results')),
      body: vm.isLoadingDashboard 
          ? const Padding(padding: EdgeInsets.all(20), child: ShimmerList(count: 3, itemHeight: 120))
          : examTypes.isEmpty 
          ? const Center(child: Text('No results published yet.'))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Exam Type Selector
          DropdownButtonFormField<String>(
            value: _selectedExamType,
            decoration: InputDecoration(
              labelText: 'Select Exam Type',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: examTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedExamType = v!),
          ),
          const SizedBox(height: 24),

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
                  percent: overallPct.clamp(0.0, 1.0),
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
                        child: Text(_selectedExamType ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 24),
          Text('Performance Analytics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),

          if (filteredResults.isNotEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final i = value.toInt();
                          if (i >= 0 && i < filteredResults.length) {
                            final subj = filteredResults[i].subject;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(subj.substring(0, subj.length > 3 ? 3 : subj.length), style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: filteredResults.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.percentage,
                          color: _gradeColor(entry.value.grade),
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),
          Text('Subject-wise Results', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),

          ...filteredResults.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            final marks = r.marks;
            final total = r.totalMarks;
            final pct = r.percentage / 100;
            final grade = r.grade;
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
                        child: Text(r.subject,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700)),
                      ),
                      Text('$marks / $total',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16, color: color)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
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
