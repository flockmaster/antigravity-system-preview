import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'statistics_view_model.dart';

class StatisticsView extends StackedView<StatisticsViewModel> {
  const StatisticsView({super.key});

  @override
  StatisticsViewModel viewModelBuilder(BuildContext context) => StatisticsViewModel();

  @override
  void onViewModelReady(StatisticsViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    StatisticsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('数据看板', style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: viewModel.navigateBack,
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildEfficiencyChart(viewModel),
                   const SizedBox(height: 24),
                   _buildGrowthChart(viewModel),
                   const SizedBox(height: 24),
                   _buildSummaryCard(viewModel), // Placeholder for summary text
                ],
              ),
            ),
    );
  }

  Widget _buildEfficiencyChart(StatisticsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: AppColors.slate200.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.violet50, borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.zap, color: AppColors.violet500, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('效率光速 (秒/组)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          viewModel.getBottomTitle(value),
                          style: const TextStyle(fontSize: 10, color: AppColors.slate400),
                        ),
                      ),
                      interval: 1,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: viewModel.efficiencySpots,
                    isCurved: true,
                    color: AppColors.violet500,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.violet500.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                maxY: viewModel.maxDuration,
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(StatisticsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: AppColors.slate200.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.orange50, borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.sprout, color: AppColors.orange500, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('成长森林 (每日词汇)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          viewModel.getBottomTitle(value),
                          style: const TextStyle(fontSize: 10, color: AppColors.slate400),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: viewModel.growthBarGroups,
                maxY: viewModel.maxWordCount > 50 ? viewModel.maxWordCount : 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(StatisticsViewModel viewModel) {
     return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blue500, AppColors.blue600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: AppColors.blue500.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: const Row(
        children: [
           Icon(LucideIcons.trophy, color: Colors.white, size: 24),
           SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('加油！', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                 SizedBox(height: 4),
                 Text('坚持就是胜利，你的进步肉眼可见！', style: TextStyle(color: Colors.white70, fontSize: 12)),
               ],
             ),
           )
        ],
      ),
     );
  }
}
