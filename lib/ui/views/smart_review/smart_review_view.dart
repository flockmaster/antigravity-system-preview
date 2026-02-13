import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui' as ui; 
import 'package:word_assistant/core/theme/app_colors.dart';
import 'smart_review_view_model.dart';

class SmartReviewView extends StackedView<SmartReviewViewModel> {
  const SmartReviewView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SmartReviewViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Matches Prototype
      body: Stack(
        children: [
          // Background Noise (Optional, skipped for performance)
          
          Column(
            children: [
              // Scrollable Content
              Expanded(
                child: viewModel.isBusy
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.isEmpty
                      ? _buildEmptyState()
                      : _buildMainContent(context, viewModel),
              ),
              
              // Bottom Action Bar (Fixed)
              if (!viewModel.isEmpty)
                _buildBottomBar(viewModel),
            ],
          ),

          // Glass Header (Sticky-like visual)
          Positioned(
            top: 0, 
            left: 0, 
            right: 0,
            child: _buildHeader(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SmartReviewViewModel viewModel) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(top: topPadding + 8, bottom: 12, left: 20, right: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC).withValues(alpha: 0.9),
            border: Border(bottom: BorderSide(color: AppColors.slate200.withValues(alpha: 0.5))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: viewModel.navigateBack,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.slate100),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset:const Offset(0, 2))
                    ]
                  ),
                  child: const Icon(LucideIcons.chevronLeft, size: 20, color: AppColors.slate600),
                ),
              ),
              const Text(
                '智能复习',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.slate900),
              ),
              const SizedBox(width: 40), // Spacer
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, SmartReviewViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 140, 24, 140), // Top pad for header & bottom bar
      physics: const BouncingScrollPhysics(),
      children: [
        // Simple Title Header
        const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今日智能推荐',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.slate900),
              ),
              SizedBox(height: 4),
              Text(
                '基于艾宾浩斯曲线与您的历史掌握情况生成',
                style: TextStyle(fontSize: 13, color: AppColors.slate500, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // List Items
        ...viewModel.smartPlan.map((word) {
           final reason = viewModel.getRecommendationReason(word);
           return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.slate200.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(color: AppColors.slate900.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Word & Reason Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            word.word,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.slate900),
                          ),
                          const SizedBox(width: 8),
                          // 播放按钮
                          GestureDetector(
                            onTap: () => viewModel.speakWord(word),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.indigo50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.volume2, size: 16, color: AppColors.indigo600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildReasonBadge(reason),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Phonetic
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      word.phonetic,
                      style: const TextStyle(fontSize: 13, fontFamily: 'RobotoMono', color: AppColors.slate500, fontWeight: FontWeight.w500),
                    ),
                  ),
                  
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.slate100),
                const SizedBox(height: 12),

                // Meaning
                Text(
                  word.meaningForDictation,
                  style: const TextStyle(fontSize: 15, color: AppColors.slate600, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReasonBadge(String reason) {
    Color bg, text;
    
    // 1. 红色系 (紧急/错误)
    if (reason.contains('消灭错题') || reason == '红灯') {
      bg = const Color(0xFFFEF2F2); // Red 50
      text = const Color(0xFFEF4444); // Red 500
    } 
    // 2. 绿色系 (新知/成长)
    else if (reason.contains('新单词')) {
      bg = const Color(0xFFDCFCE7); // Green 100
      text = const Color(0xFF16A34A); // Green 600
    } 
    // 3. 橙色系 (警示/易错)
    else if (reason.contains('高频易错') || reason.contains('未毕业')) {
      bg = const Color(0xFFFFF7ED); // Orange 50
      text = const Color(0xFFF97316); // Orange 500
    }
    // 4. 琥珀色系 (唤醒/珍贵)
    else if (reason.contains('唤醒记忆')) {
      bg = const Color(0xFFFEF3C7); // Amber 100
      text = const Color(0xFFD97706); // Amber 600
    }
    // 5. 蓝色系 (理性/周期)
    else if (reason.contains('记忆周期')) {
      bg = const Color(0xFFEFF6FF); // Blue 50
      text = const Color(0xFF2563EB); // Blue 600
    }
    // 6. 紫色系 (智慧/默认)
    else {
      bg = const Color(0xFFEEF2FF); // Indigo 50
      text = const Color(0xFF4F46E5); // Indigo 600
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: text.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.sparkles, size: 10, color: text),
          const SizedBox(width: 4),
          Text(
            reason,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: text),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.brain, size: 48, color: AppColors.slate300),
          SizedBox(height: 16),
          Text(
            '词库还是空的',
            style: TextStyle(fontSize: 16, color: AppColors.slate400),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(SmartReviewViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: AppColors.slate200.withValues(alpha: 0.5))),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: ClipRect( // Backdrop workaround
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // Step Mode (Progressive Learning)
              Expanded(
                child: GestureDetector(
                  onTap: viewModel.startLearningSession,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.slate100, width: 2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.layers, size: 18, color: Color(0xFFF97316)), // Orange 500
                            SizedBox(width: 4),
                            Text('阶梯学习', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slate600)),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text('STEP MODE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.slate400, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Deep Mode
              Expanded(
                child: GestureDetector(
                  onTap: viewModel.startDictationSession,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A), // Slate 900
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8))
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.penTool, size: 18, color: Color(0xFFC4B5FD)), // Violet 300
                            SizedBox(width: 4),
                            Text('强化听写', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text('DEEP MODE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.slate400, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  SmartReviewViewModel viewModelBuilder(BuildContext context) => SmartReviewViewModel();

  @override
  void onViewModelReady(SmartReviewViewModel viewModel) => viewModel.init();
}
