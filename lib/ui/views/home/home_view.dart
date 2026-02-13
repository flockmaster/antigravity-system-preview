import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'home_view_model.dart';
// Keep for HomeHeader if reused
import 'widgets/home_feature_slider.dart'; // NEW
import 'widgets/heterogeneous_card.dart'; // NEW
import '../../../core/models/dictation_session.dart';


class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    // Edge-to-Edge: Safe Area handling
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.slate50, // Matches bg-[#F8F9FC]
      body: RefreshIndicator(
        onRefresh: viewModel.refreshData,
        color: AppColors.violet600,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: 0, // Header is now inside
            bottom: 120 + bottomPadding, // Spacing for Main TabBar
          ),
          children: [
            // 1. Header (Now scrolls)
            _buildHeader(context, topPadding, viewModel),


            // Feature Slider (Camera / Paste)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: HomeFeatureSlider(
                onScanTap: viewModel.navigateToScanBook,
                onPasteTap: viewModel.navigateToPasteText,
              ),
            ),

            // Heterogeneous Cards (Mistake & Vocabulary)
            _buildStatsGrid(viewModel),

            const SizedBox(height: 32),

            // Recent History
            _buildRecentHistory(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding, HomeViewModel viewModel) {

    return Container(
      padding: EdgeInsets.only(top: topPadding + 16, bottom: 24, left: 24, right: 24),
      color: Colors.transparent, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppColors.violet500, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'DICTATION PAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7C3AED), // violet-600
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '你好，${viewModel.nickname} ',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.slate900,
                            letterSpacing: -1.0,
                            height: 1.1,
                          ),
                        ),

                        const TextSpan(text: '👋', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Points Display Row Removed

            ],
          ),

          // Avatar
          GestureDetector(
            onTap: viewModel.navigateToPersonalCenter,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate200.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset('assets/images/avatar_boy.png', fit: BoxFit.cover), // Using existing asset
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildStatsGrid(HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24), // px-6
      child: Column(
        children: [
          // 1. Action Cards Row (Mistakes & Smart Review)
          Row(
            children: [
              // Mistake Crusher
              Expanded(
                child: HeterogeneousCard(
                  title: '错题本', // Mistake Book
                  subtitle: viewModel.mistakeCount > 0 ? '消灭错题' : '太棒了',
                  count: viewModel.mistakeCount,
                  icon: viewModel.mistakeCount > 0 ? LucideIcons.alertCircle : LucideIcons.trophy,
                  actionIcon: viewModel.mistakeCount > 0 ? LucideIcons.arrowUpRight : LucideIcons.shieldCheck,
                  isActive: viewModel.mistakeCount > 0,
                  activeColor: AppColors.red500,
                  activeIconColor: AppColors.red500,
                  activeBackgroundColor: AppColors.red50,
                  onTap: viewModel.navigateToReviewMistakes,
                ),
              ),
              const SizedBox(width: 20), // gap-5
              
              // Smart Review (Memory Guard)
              Expanded(
                child: HeterogeneousCard(
                  title: '智能复习', // Smart Review
                  subtitle: viewModel.reviewCount > 0 ? '一键抢救' : '记忆暂存',
                  count: viewModel.reviewCount,
                  icon: LucideIcons.brainCircuit, // Using brain circuit if available, else zap
                  actionIcon: viewModel.reviewCount > 0 ? LucideIcons.play : LucideIcons.check,
                  isActive: viewModel.reviewCount > 0,
                  activeColor: AppColors.emerald500,
                  activeIconColor: AppColors.emerald500,
                  activeBackgroundColor: AppColors.emerald50,
                  // TODO: Should navigate to Smart Review Session or Filtered Library
                  onTap: viewModel.navigateToSmartReview, 
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Asset Card (My Library) - Full Width
          _buildLibraryCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildLibraryCard(HomeViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.navigateToReviewVocabulary,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [
             BoxShadow(
               color: AppColors.indigo500.withValues(alpha: 0.08),
               blurRadius: 20,
               offset: const Offset(0, 8),
             ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background gradient (Subtle)
            Positioned(
              right: 0, top: 0, bottom: 0,
              width: 120,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.indigo50.withValues(alpha: 0.0),
                      AppColors.indigo50.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.indigo50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.indigo500.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(LucideIcons.library, color: AppColors.indigo500, size: 24),
                  ),
                  const SizedBox(width: 20),
                  
                  // Text Info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '我的词库',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.emerald50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '今日新学会 +${viewModel.todayMasteredCount}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.emerald500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Total Count
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${viewModel.vocabularyCount}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.slate900,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        'Total Words',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Final Arrow
                  const Icon(LucideIcons.chevronRight, color: AppColors.slate300, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory(HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24), // px-6
      child: Column(
        children: [
          // Section Title
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Icon(LucideIcons.history, size: 12, color: AppColors.slate400),
                SizedBox(width: 8),
                Text(
                  '最近记录',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate400,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          if (viewModel.recentSessions.isEmpty) ...[
             // Empty State (Simplified)
             Container(
               padding: const EdgeInsets.all(32),
               alignment: Alignment.center,
               child: const Text('还没有听写记录', style: TextStyle(color: AppColors.slate400)),
             )
          ] else ...[
             ...viewModel.recentSessions.map((session) => _buildHistoryRow(session, viewModel)),
          ]
        ],
      ),
    );
  }

  Widget _buildHistoryRow(Map<String, dynamic> session, HomeViewModel viewModel) {
    // Mode Logic
    final rawMode = session['mode'] as String?;
    final mode = parseDictationMode(rawMode);
    String modeTitle = mode.label;
    String modeSubtitle = mode.subtitle;

    // Score Logic
    final score = session['score'] as int? ?? 0;
    final isFullScore = score == 100;

    // Time Logic
    final dateStr = session['date'] as String?;
    String timeDisplay = '刚刚';
    if (dateStr != null) {
       final date = DateTime.tryParse(dateStr);
       if (date != null) {
         final diff = DateTime.now().difference(date);
         if (diff.inSeconds < 60) {
           timeDisplay = '刚刚';
         } else if (diff.inMinutes < 60) {
           timeDisplay = '${diff.inMinutes}分钟前';
         } else if (diff.inHours < 24) {
           timeDisplay = '${diff.inHours}小时前';
         } else {
           timeDisplay = '${date.month}月${date.day}日';
         }
      }
    }

    // Duration Logic - 完成时长
    final durationSeconds = session['duration_seconds'] as int?;
    String? durationDisplay;
    if (durationSeconds != null && durationSeconds > 0) {
      final minutes = durationSeconds ~/ 60;
      final seconds = durationSeconds % 60;
      if (minutes > 0) {
        durationDisplay = '$minutes分$seconds秒';
      } else {
        durationDisplay = '$seconds秒';
      }
    }

    return GestureDetector(
      onTap: () => viewModel.viewSessionHistory(session),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.04),
               blurRadius: 30,
               offset: const Offset(0, 8),
             ),
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.02),
               blurRadius: 3,
               offset: const Offset(0, 1),
             ),
          ],
        ),
        child: Row(
          children: [
            // Score Box
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: mode.color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Center( // Only score now
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 20, // Slightly larger since it's alone
                    fontWeight: FontWeight.w900,
                    color: mode.iconColor,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modeTitle, // Mode Name as Title
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        timeDisplay, 
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate400,
                         ),
                      ),
                      const SizedBox(width: 8),
                      // Dot
                      Container(width: 2, height: 2, color: AppColors.slate300, margin: const EdgeInsets.only(right: 8)),
                      // Tag (Now showing subtitle)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          modeSubtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 显示完成时长
                  if (durationDisplay != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 10, color: AppColors.violet500),
                        const SizedBox(width: 4),
                        Text(
                          '用时 $durationDisplay',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.violet600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow Circle
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFullScore ? AppColors.emerald100 : AppColors.slate100,
                  width: 2,
                ),
              ),
              child: Icon(
                LucideIcons.chevronRight, 
                size: 16, 
                color: isFullScore ? AppColors.emerald500 : AppColors.slate300, 
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    viewModel.init();
  }

  @override
  bool get fireOnViewModelReadyOnce => false;

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
