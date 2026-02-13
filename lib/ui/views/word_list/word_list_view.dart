import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../views/common/empty_view.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'word_list_view_model.dart';
import '../../../core/models/word.dart';

class WordListView extends StackedView<WordListViewModel> {
  final bool isLibrary;
  final bool isMistakes;
  final bool isSmartReview; 
  const WordListView({
    super.key,
    this.isLibrary = false,
    this.isMistakes = false,
    this.isSmartReview = false,
  });

  @override
  Widget builder(
    BuildContext context,
    WordListViewModel viewModel,
    Widget? child,
  ) {
    // Determine if we are in Import Mode (Not Library, Not Mistake)
    final isImportMode = !viewModel.isLibraryMode && !viewModel.isMistakeMode;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(viewModel, isImportMode),
            
            // List or Empty State
            if (viewModel.isBusy)
               const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (viewModel.words.isEmpty)
               Expanded(
                 child: EmptyView(
                   imagePath: viewModel.isMistakeMode 
                       ? 'assets/images/img_empty_mistake.png' 
                       : 'assets/images/img_empty_library.png',
                   title: viewModel.isMistakeMode ? '全军覆没！' : '暂时没有单词',
                   subtitle: viewModel.isMistakeMode 
                       ? '不管是新词还是老顽固，都被你消灭了。\n保持这个势头！' 
                       : '快去添加一些新单词吧',
                 ),
               )
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, isImportMode ? 140 : 48),
                  physics: const BouncingScrollPhysics(),
                  itemCount: viewModel.words.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final word = viewModel.words[index];
                    return _buildWordCard(word, viewModel);
                  },
                ),
              ),

             // Bottom Buttons (Import Mode Only)
             if (isImportMode && !viewModel.isBusy && viewModel.words.isNotEmpty)
               _buildBottomButtons(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WordListViewModel viewModel, bool isImportMode) {
    String title;
    if (isImportMode) {
      title = '确认单词';
    } else if (viewModel.isMistakeMode) {
      title = '错题本';
    } else if (viewModel.isSmartReviewMode) {
      title = '智能复习';
    } else {
      title = '我的词库';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: Color(0x80E2E8F0))),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: viewModel.onRetake,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.slate100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.chevronLeft, color: AppColors.slate600, size: 20),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mode Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      
                      // Segmented Control (Only in Library Mode)
                      if (viewModel.isLibraryMode) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 32,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSegmentTab(viewModel, 0, '遗忘危机'),
                              _buildSegmentTab(viewModel, 1, '学习中'),
                              _buildSegmentTab(viewModel, 2, '全部'),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 2),
                        Text(
                          '已选 ${viewModel.selectedCount} 个',
                          style: const TextStyle(fontSize: 11, color: AppColors.slate400),
                        ),
                      ]
                    ],
                  ),
                ),
                // Right Action Button (Only if NOT import mode - import mode has bottom buttons)
                if (!isImportMode)
                  GestureDetector(
                    onTap: viewModel.hasSelection ? viewModel.onImportAndLearn : null, // Reuse for "Start Learning"
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: viewModel.hasSelection ? AppColors.violet600 : AppColors.slate100,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: viewModel.hasSelection ? [
                          BoxShadow(
                            color: AppColors.violet600.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: viewModel.isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '开始学习',
                            style: TextStyle(
                              color: viewModel.hasSelection ? Colors.white : AppColors.slate300,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  )
                else
                   const SizedBox(width: 40), // Placeholder for symmetry
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 底部双按钮区域（导入模式专用）
  Widget _buildBottomButtons(WordListViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 左侧次要按钮：仅导入词库
            Expanded(
              child: GestureDetector(
                onTap: viewModel.hasSelection ? viewModel.onImportOnly : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: viewModel.hasSelection ? AppColors.slate100 : AppColors.slate50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: viewModel.hasSelection ? AppColors.slate200 : AppColors.slate100,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.download,
                        size: 16,
                        color: viewModel.hasSelection ? AppColors.slate600 : AppColors.slate300,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '仅导入词库',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: viewModel.hasSelection ? AppColors.slate600 : AppColors.slate300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 右侧主按钮：导入并开始学习
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: viewModel.hasSelection ? viewModel.onImportAndLearn : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: viewModel.hasSelection
                        ? const LinearGradient(
                            colors: [AppColors.violet500, AppColors.violet600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: viewModel.hasSelection ? null : AppColors.slate100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: viewModel.hasSelection
                        ? [
                            BoxShadow(
                              color: AppColors.violet500.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: viewModel.isBusy
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.graduationCap,
                              size: 16,
                              color: viewModel.hasSelection ? Colors.white : AppColors.slate300,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '开始学习',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: viewModel.hasSelection ? Colors.white : AppColors.slate300,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab(WordListViewModel viewModel, int index, String label) {
    final isSelected = viewModel.tabIndex == index;
    return GestureDetector(
      onTap: () => viewModel.setTabIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? AppColors.slate900 : AppColors.slate500,
          ),
        ),
      ),
    );
  }

  Widget _buildWordCard(Word word, WordListViewModel viewModel) {
    final isSelected = viewModel.isSelected(word.id);
    final showSentence = viewModel.isMistakeMode || isSelected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.violet500 : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected ? [
           BoxShadow(
             color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
             blurRadius: 20,
             offset: const Offset(0, 4),
           )
        ] : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Left Learning Area (80%)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => viewModel.speakWord(word), // Speak on tap
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Word + Speaker
                  Row(
                    children: [
                      Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.slate900 : AppColors.slate500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.volume2, size: 16, color: AppColors.violet500.withValues(alpha: 0.7)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Phonetic + Graduation Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.slate100, borderRadius: BorderRadius.circular(4)),
                        child: Text(word.phonetic, style: const TextStyle(fontSize: 10, fontFamily: 'SF Mono', color: AppColors.slate500)),
                      ),
                      const SizedBox(width: 8),
                      if (word.isGraduated)
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                             color: Colors.amber.withValues(alpha: 0.2), 
                             borderRadius: BorderRadius.circular(4),
                             border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 0.5),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               const Icon(LucideIcons.award, size: 10, color: Colors.amber),
                               const SizedBox(width: 4),
                               Text(
                                 '已毕业', 
                                 style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber[800])
                               ),
                             ],
                           ),
                         ),
                    ],
                  ),

                  // Definition
                  const SizedBox(height: 8),
                  Text(
                    word.meaningFull, // Use meaningFull to show definition
                    style: const TextStyle(fontSize: 14, color: AppColors.slate700, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Sentence Area (Visible if Mistake or Selected)
                  if (showSentence && word.sentence.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        word.sentence,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.slate600,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // B. Right Selection Area (20%) - Checkbox/Button
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => viewModel.toggleSelection(word.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.violet500 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.violet500 : AppColors.slate300,
                  width: 2,
                ),
              ),
              child: isSelected 
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white) 
                  : null, 
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onViewModelReady(WordListViewModel viewModel) {
    viewModel.init(
      isLibrary: isLibrary, 
      isMistakes: isMistakes,
      isSmartReview: isSmartReview,
    );
  }

  @override
  WordListViewModel viewModelBuilder(BuildContext context) => WordListViewModel();
}
