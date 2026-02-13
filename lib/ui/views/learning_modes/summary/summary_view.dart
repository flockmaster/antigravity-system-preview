import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'summary_view_model.dart';
import 'package:word_assistant/core/theme/app_colors.dart';

class SummaryView extends StackedView<SummaryViewModel> {
  const SummaryView({super.key});

  @override
  SummaryViewModel viewModelBuilder(BuildContext context) => SummaryViewModel();

  @override
  void onViewModelReady(SummaryViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    SummaryViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Score Card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violet500.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                  child: Column(
                    children: [
                      const Text(
                        '挑战完成!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Score Circle
                      Container(
                        width: 160,
                        height: 160,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.violet100, width: 8),
                          color: AppColors.violet50,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${viewModel.score}',
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: AppColors.violet600,
                                height: 1.0,
                              ),
                            ),
                            const Text(
                              '本次得分',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.violet400,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Stats Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('总词数', '${viewModel.totalWords}', AppColors.slate500),
                          _buildStatItem('正确', '${viewModel.correctCount}', AppColors.emerald500),
                          _buildStatItem('错误', '${viewModel.errorCount}', AppColors.red500),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: viewModel.onExit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.slate900,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('返回首页', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildStatItem(String label, String value, Color color) {
      return Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.slate400),
          ),
        ],
      );
    }
}
