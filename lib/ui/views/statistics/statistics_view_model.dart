import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/services/database_service.dart';
import '../../../core/models/study_stat.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class StatisticsViewModel extends BaseViewModel {
  final _dbService = locator<DatabaseService>();
  final _navigationService = locator<NavigationService>(); // Assuming available if needed

  List<StudyStat> _stats = [];
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Chart Data
  List<FlSpot> _efficiencySpots = [];
  List<FlSpot> get efficiencySpots => _efficiencySpots;
  

  List<BarChartGroupData> _growthBarGroups = [];
  List<BarChartGroupData> get growthBarGroups => _growthBarGroups;

  double _maxDuration = 600; // Default max Y for efficiency chart
  double get maxDuration => _maxDuration;

  double _maxWordCount = 50;
  double get maxWordCount => _maxWordCount;

  void init() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    // Load last 14 days of data
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 14));
    
    _stats = await _dbService.getStudyStats(start: start, end: end);
    
    _processEfficiencyData();
    _processGrowthData();

    _isLoading = false;
    notifyListeners();
  }

  void _processEfficiencyData() {
    _efficiencySpots = [];
    
    // Filter for smart review sessions only for efficiency chart
    final reviewStats = _stats.where((s) => s.sessionType == 'smart_review').toList();
    
    if (reviewStats.isEmpty) return;

    // Group by day and take average duration? Or show all points?
    // Let's show average duration per day to make it smoother

    
    // Re-approach: 
    // X-Axis: 0 to 6 (Last 7 days for visibility)
    // Let's chart the last 7 sessions directly or last 7 days averages.
    // User asked for "Efficiency trend", usually per day.

    final now = DateTime.now();
    // Prepare slots for last 7 days [6 days ago ... today]
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      
      final dayStats = reviewStats.where((s) => s.date == dateStr).toList();
      
      if (dayStats.isNotEmpty) {
        // Calculate average duration
        final avgDuration = dayStats.map((e) => e.durationSeconds).reduce((a, b) => a + b) / dayStats.length;
        _efficiencySpots.add(FlSpot((6 - i).toDouble(), avgDuration));
        
        if (avgDuration > _maxDuration) _maxDuration = avgDuration * 1.2;
      }
    }
  }

  void _processGrowthData() {
    _growthBarGroups = [];
    
    final now = DateTime.now();
    
    // Last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      
      final dayStats = _stats.where((s) => s.date == dateStr).toList();
      final totalWords = dayStats.fold<int>(0, (sum, item) => sum + item.wordCount);
      
      _growthBarGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: totalWords.toDouble(),
              color: AppColors.orange500,
              width: 12,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 50, // Benchmark target
                color: AppColors.slate100,
              ),
            ),
          ],
        ),
      );
      
      if (totalWords > _maxWordCount) _maxWordCount = totalWords * 1.2;
    }
  }

  String getBottomTitle(double value) {
    // value is 0..6
    final index = value.toInt();
    if (index < 0 || index > 6) return '';
    
    final date = DateTime.now().subtract(Duration(days: 6 - index));
    return '${date.day}日';
  }

  void navigateBack() {
    _navigationService.back(); // Use specific service if needed
  }
}
