import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:word_assistant/core/theme/app_colors.dart';

class LibraryAnalyticsWidgets {
  
  static Widget buildTrendChart(BuildContext context) {
    // Mock Data: 30 days of accumulation
    // In real app, this should come from ViewModel
    final spots = <FlSpot>[];
    for (int i = 0; i < 30; i++) {
        double y = (i * 2) + (i * i * 0.1) + 10; // Simulated curve
        spots.add(FlSpot(i.toDouble(), y));
    }

    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
         boxShadow: [
          BoxShadow(
            color: AppColors.indigo600.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '30天词汇积累',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate500),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.indigo600,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.indigo600.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildMasteryRing(BuildContext context, {
    required int mastered,
    required int learning,
    required int newWords
  }) {
    final total = mastered + learning + newWords;
    if (total == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '掌握度分布',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate500),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Ring
              SizedBox(
                height: 100,
                width: 100,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                          value: mastered.toDouble(),
                          color: const Color(0xFF22C55E), // Green
                          radius: 16,
                          showTitle: false),
                      PieChartSectionData(
                          value: learning.toDouble(),
                          color: const Color(0xFFEAB308), // Yellow
                          radius: 16,
                          showTitle: false),
                      PieChartSectionData(
                          value: newWords.toDouble(),
                          color: AppColors.slate200, // Gray
                          radius: 16,
                          showTitle: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('已掌握', mastered, const Color(0xFF22C55E)),
                    const SizedBox(height: 8),
                    _buildLegendItem('学习中', learning, const Color(0xFFEAB308)),
                    const SizedBox(height: 8),
                    _buildLegendItem('新词汇', newWords, AppColors.slate400),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
        const Spacer(),
        Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate900)),
      ],
    );
  }
}
