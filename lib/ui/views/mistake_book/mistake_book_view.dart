import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'mistake_book_view_model.dart';
import 'widgets/mistake_card.dart';

class MistakeBookView extends StackedView<MistakeBookViewModel> {
  const MistakeBookView({super.key});

  @override
  Widget builder(
    BuildContext context,
    MistakeBookViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Matches Prototype bg-[#F8F9FC]
      body: Stack(
        children: [
          // Background Noise (Optional, skipped for Flutter performance or use image)
          
          Column(
            children: [
              // Content List
              Expanded(
                child: viewModel.isBusy
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.mistakeWords.isEmpty
                      ? _buildEmptyState()
                      : _buildList(viewModel),
              ),
            ],
          ),

          // Glass Header (Absolute Positioned)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context, viewModel),
          ),

          // Floating Action Button Area
          if (!viewModel.isBusy && viewModel.mistakeWords.isNotEmpty)
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: _buildStartButton(viewModel),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MistakeBookViewModel viewModel) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(top: topPadding + 12, bottom: 16, left: 24, right: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC).withValues(alpha: 0.9),
            border: const Border(bottom: BorderSide(color: Color(0x80E2E8F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              GestureDetector(
                onTap: viewModel.navigateBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.slate100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Icon(LucideIcons.chevronLeft, color: AppColors.slate600, size: 20),
                ),
              ),

              // Title
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '错题复习',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '已选 ${viewModel.selectedCount} / ${viewModel.mistakeWords.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),

              // Select All Toggle
              GestureDetector(
                onTap: viewModel.toggleSelectAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.transparent, // Hit test
                  child: Text(
                    viewModel.isAllSelected ? '全不选' : '全选',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate500,
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

  Widget _buildEmptyState() {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Container(
             width: 80, height: 80,
             decoration: const BoxDecoration(
               color: AppColors.slate100,
               shape: BoxShape.circle,
             ),
             child: const Icon(LucideIcons.check, size: 40, color: AppColors.slate400),
           ),
           const SizedBox(height: 16),
           const Text(
             '太棒了！错题本已清空',
             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slate400),
           ),
         ],
       ),
     );
  }

  Widget _buildList(MistakeBookViewModel viewModel) {
     return ListView(
       padding: const EdgeInsets.fromLTRB(24, 140, 24, 120), // Top pad for header, bottom for FAB
       physics: const BouncingScrollPhysics(),
       children: [
         // Context Banner
         Container(
           margin: const EdgeInsets.only(bottom: 24),
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(16),
             border: Border.all(color: AppColors.slate100),
             boxShadow: [
               BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
             ],
           ),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Padding(
                 padding: EdgeInsets.only(top: 2.0),
                 child: Icon(LucideIcons.bookOpen, size: 18, color: AppColors.slate900),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text(
                       '复习模式',
                       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate900),
                     ),
                     const SizedBox(height: 4),
                     RichText(
                       text: const TextSpan(
                         style: TextStyle(fontSize: 12, color: AppColors.slate500, height: 1.5, fontFamily: 'Roboto'), // Default font
                         children: [
                           TextSpan(text: '点击卡片选中要攻克的单词。点击 '),
                           WidgetSpan(child: Icon(LucideIcons.volume2, size: 12, color: AppColors.slate400)),
                           TextSpan(text: ' 图标朗读，准备好后开始听写。'),
                         ],
                       ),
                     ),
                   ],
                 ),
               )
             ],
           ),
         ),

         // List Items
         ...viewModel.mistakeWords.map((word) => Padding(
           padding: const EdgeInsets.only(bottom: 16.0),
           child: MistakeCard(
             word: word,
             isSelected: viewModel.isSelected(word.id),
             onTap: () => viewModel.toggleSelection(word.id),
             onPlayAudio: viewModel.speakWord,
           ),
         )),
       ],
     );
  }

  Widget _buildStartButton(MistakeBookViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.hasSelection ? viewModel.startPractice : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          color: viewModel.hasSelection ? AppColors.slate900 : AppColors.slate200,
          borderRadius: BorderRadius.circular(24),
          boxShadow: viewModel.hasSelection ? [
            BoxShadow(
              color: AppColors.slate900.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.play, 
              size: 20, 
              color: viewModel.hasSelection ? Colors.white : AppColors.slate400,
            ),
            const SizedBox(width: 12),
            Text(
              viewModel.hasSelection ? '开始攻克 (${viewModel.selectedCount})' : '请选择单词',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: viewModel.hasSelection ? Colors.white : AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(MistakeBookViewModel viewModel) {
    viewModel.init();
  }

  @override
  MistakeBookViewModel viewModelBuilder(BuildContext context) => MistakeBookViewModel();
}
