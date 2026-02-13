import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'result_view_model.dart';
import '../../../core/models/dictation_session.dart';

class ResultView extends StackedView<ResultViewModel> {
  const ResultView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ResultViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final result = viewModel.result!;
    final bool isPerfect = result.score == 100;
    final bool isGood = result.score > 80;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Top Background Half-Circle
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
            ),
          ),

          // 2. Main Content Layer
          Positioned.fill(
            child: Column(
              children: [
                // Upper Area: Score Sphere & Text
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Score Sphere with Decorations
                        AnimatedScoreSphere(
                          score: result.score, 
                          isGood: isGood,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Result Title
                        Text(
                          isPerfect ? '满分！太棒了！' : (isGood ? '做得不错！' : '继续加油'),
                          style: const TextStyle(
                            fontSize: 24, // text-2xl
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        
                        const SizedBox(height: 8),

                        // Result Subtitle
                        Text(
                          '你掌握了 ${result.total} 个单词中的 ${result.total - result.mistakes.length} 个。',
                          style: const TextStyle(
                            fontSize: 14, // text-sm
                            color: AppColors.slate500,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Points Earned Tag (Animated & Prominent)
                        if (viewModel.pointsEarned > 0)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 主积分标签
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFBBF24), Color(0xFFFB923C)], // amber-400 to orange-400
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(100),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFF97316).withValues(alpha: 0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.coins, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            '+${viewModel.pointsEarned} 积分',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // 积分明细 (T2.1: 基础分 + Combo 奖励)
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '基础分 +${viewModel.basePoints}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.slate500,
                                          ),
                                        ),
                                        if (viewModel.comboBonus > 0) ...[
                                          const SizedBox(width: 12),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(LucideIcons.flame, color: Color(0xFFFF6B6B), size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                '连击奖励 +${viewModel.comboBonus}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFFF6B6B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 32),
                        
                        // 3. Dimension Analysis (New Feature)
                        if (result.stats != null) 
                          _buildDimensionAnalysis(result),
                      ],
                    ),
                  ),
                ),

                // Lower Area: Detail List (Slide up card)
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 40,
                          offset: const Offset(0, -10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 32, bottom: 16, left: 32),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                               '学习详情', // Changed from "Detail" to "Learning Detail"
                               style: const TextStyle(
                                 fontSize: 14,
                                 fontWeight: FontWeight.bold,
                                 color: AppColors.slate400,
                                 letterSpacing: 1.2,
                               ),
                            ),
                          ),
                        ),
                        
                        // Mistake List or Perfect State (Now shows ALL items)
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              // Prefer allItems if available, otherwise fallback (e.g. for history without full logs)
                              final items = result.allItems ?? result.mistakes;
                              if (items.isEmpty && result.mistakes.isEmpty) {
                                // Only show perfect state if we truly have NO logs and NO mistakes (shouldn't happen for new sessions)
                                return _buildPerfectState(); 
                              }
                              
                              // Sort: Mistakes first
                              final displayList = List<Mistake>.from(items);
                              displayList.sort((a, b) {
                                if (!a.isCorrect && b.isCorrect) return -1;
                                if (a.isCorrect && !b.isCorrect) return 1;
                                return 0;
                              });

                              return ListView.separated(
                                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                                physics: const BouncingScrollPhysics(),
                                itemCount: displayList.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  return _buildResultItem(displayList[index]);
                                },
                              );
                            }
                          ),
                        ),

                        // Bottom Button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                          child: GestureDetector(
                            onTap: viewModel.goHome,
                            child: Container(
                              height: 64,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.slate900,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.slate200,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '返回首页',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build result item (Unified for Mistake/Correct)
  Widget _buildResultItem(Mistake item) {
    if (item.isCorrect) {
      // Correct Item
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate100),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.emerald50,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.check, color: AppColors.emerald500, size: 16),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                   item.word,
                   style: const TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                     color: AppColors.slate900,
                   ),
                ),
                if (item.mode != null) ...[
                   const SizedBox(height: 2),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(
                       color: AppColors.slate50,
                       borderRadius: BorderRadius.circular(4),
                     ),
                     child: Text(
                       item.mode!.label,
                       style: const TextStyle(fontSize: 10, color: AppColors.slate400),
                     ),
                   ),
                ]
              ],
            ),
            const Spacer(),
          ],
        ),
      );
    } else {
      // Incorrect Item
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED).withValues(alpha: 0.5), // orange-50
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.orange100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: const Icon(LucideIcons.x, color: AppColors.orange500, size: 16),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.word,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mode Tag
                      if (item.mode != null)
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                             color: item.mode!.color, // Use mode color
                             borderRadius: BorderRadius.circular(4),
                           ),
                           child: Text(
                             item.mode!.label,
                             style: TextStyle(
                               fontSize: 10, 
                               fontWeight: FontWeight.bold,
                               color: item.mode!.iconColor,
                             ),
                           ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // User Input
                  RichText(
                    text: TextSpan(
                      text: '你的回答： ',
                      style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                      children: [
                        TextSpan(
                          text: item.studentInput?.isNotEmpty == true ? item.studentInput : "未填写",
                          style: const TextStyle(
                            color: AppColors.orange600,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Color(0xFFFDBA74), // orange-300
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Correct Answer
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: '正确答案： ',
                      style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                      children: [
                         TextSpan(
                          text: item.correctAnswer ?? item.word, // Fallback to word if standard answer missing
                          style: const TextStyle(
                            color: AppColors.emerald600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // Legacy alias
  Widget _buildMistakeCard(Mistake mistake) => _buildResultItem(mistake);

  Widget _buildDimensionAnalysis(SessionResult result) {
    if (result.stats == null) return const SizedBox();

    final stats = result.stats!;
    // Calculate Mistakes per mode
    final mistakesA = result.mistakes.where((m) => m.mode == DictationMode.modeA).length;
    final mistakesB = result.mistakes.where((m) => m.mode == DictationMode.modeB).length;
    final mistakesC = result.mistakes.where((m) => m.mode == DictationMode.modeC).length;
    
    final totalA = stats['total_A'] ?? 0;
    final totalB = stats['total_B'] ?? 0;
    final totalC = stats['total_C'] ?? 0;

    // Helper to build row
    Widget buildRow(String label, int total, int mistakes, Color color) {
       if (total == 0) return const SizedBox(); // Skip if no items for this mode
       final correct = total - mistakes;
       final percent = total > 0 ? correct / total : 0.0;
       
       return Padding(
         padding: const EdgeInsets.only(bottom: 8.0),
         child: Row(
           children: [
             SizedBox(
               width: 30, // Fixed width label
               child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.slate400)),
             ),
             const SizedBox(width: 8),
             Expanded(
               child: Stack(
                 children: [
                   Container(
                     height: 6,
                     decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(3)),
                   ),
                   FractionallySizedBox(
                     widthFactor: percent,
                     child: Container(
                       height: 6,
                       decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                     ),
                   )
                 ],
               ),
             ),
             const SizedBox(width: 12),
             Text(
               '${(percent * 100).toInt()}%',
               style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
             ),
           ],
         ),
       );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          buildRow('拼写', totalA, mistakesA, AppColors.violet500),
          buildRow('翻译', totalB, mistakesB, AppColors.orange500),
          buildRow('释义', totalC, mistakesC, AppColors.emerald500),
        ],
      ),
    );
  }

  Widget _buildPerfectState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(LucideIcons.trophy, size: 48, color: AppColors.slate200),
           SizedBox(height: 16),
           Text(
             '本次没有错误',
             style: TextStyle(
               color: AppColors.slate300,
               fontSize: 14,
               fontWeight: FontWeight.bold,
             ),
           )
        ],
      ),
    );
  }

  @override
  ResultViewModel viewModelBuilder(BuildContext context) => ResultViewModel();
}

class AnimatedScoreSphere extends StatefulWidget {
  final int score;
  final bool isGood;

  const AnimatedScoreSphere({
    super.key,
    required this.score,
    required this.isGood,
  });

  @override
  State<AnimatedScoreSphere> createState() => _AnimatedScoreSphereState();
}

class _AnimatedScoreSphereState extends State<AnimatedScoreSphere> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // The Sphere
          Container(
            width: 192, // w-48
            height: 192, // h-48
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slate100, width: 12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), // shadow-2xl approx
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.score}',
                  style: const TextStyle(
                    fontSize: 60, // text-6xl
                    fontWeight: FontWeight.w900, // font-black
                    color: AppColors.slate900,
                    letterSpacing: -2, // tracking-tighter
                    height: 1.0,
                  ),
                ),
                const Text(
                  '本次得分',
                  style: TextStyle(
                    fontSize: 12, // text-xs
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate400,
                    letterSpacing: 2, // tracking-widest
                  ),
                ),
              ],
            ),
          ),
          
          // Decorations (Conditional)
          if (widget.isGood) ...[
            // Top Right Sparkle
            Positioned(
              top: -4,
              right: -4,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -10 * _controller.value), // Bounce up 10px
                    child: child,
                  );
                },
                child: const Icon(LucideIcons.sparkles, color: Color(0xFFFACC15), size: 48),
              ),
            ),
            // Bottom Left Dot
            Positioned(
              bottom: 20,
              left: 0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.4 * _controller.value), // Pulse size
                    child: child,
                  );
                },
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.violet600,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Middle Right Dot
            Positioned(
              top: 100,
              right: -10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.indigo600,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
