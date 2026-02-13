import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'text_input_view_model.dart';

class TextInputView extends StackedView<TextInputViewModel> {
  const TextInputView({super.key});

  @override
  Widget builder(
    BuildContext context,
    TextInputViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(viewModel),
            
            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '请将微信群或备忘录中的单词作业直接粘贴在下方。AI 会自动去除干扰文字。',
                      style: TextStyle(
                        color: AppColors.slate500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5, // leading-relaxed
                      ),
                    ),
                    const SizedBox(height: 16), // mb-4
                    
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: viewModel.isFocused ? AppColors.violet500 : AppColors.slate200,
                            width: 2,
                          ),
                          boxShadow: viewModel.isFocused 
                            ? [
                                BoxShadow(
                                  color: AppColors.violet500.withValues(alpha: 0.1),
                                  blurRadius: 0,
                                  spreadRadius: 4,
                                )
                              ] 
                            : [],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: viewModel.textController,
                          focusNode: viewModel.focusNode,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(
                            fontSize: 18, // text-lg
                            color: AppColors.slate900,
                            fontWeight: FontWeight.w500,
                            height: 1.6, // leading-relaxed
                          ),
                          decoration: const InputDecoration(
                            hintText: '例如：\n\n各位家长好，今日复习单词：\napple 苹果\nbanana 香蕉\n请督促孩子背诵。',
                            hintStyle: TextStyle(color: AppColors.slate300),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) => viewModel.notifyListeners(), 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Action
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate100)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48), // p-6 pb-12
              child: _buildExtractButton(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextInputViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: Color(0x80E2E8F0))), // slate-200/50
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // backdrop-blur-xl
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 16), // px-6 pt-14(adjusted for safe area inside col) pb-4
            // Since we are inside SafeArea, pt-14 is not needed relative to screen top, but relative to SAFE AREA?
            // React: pt-14 is for status bar usually. Here SafeArea handles status bar.
            // React padding: pt-14 px-6 pb-4.
            // Let's use standard padding for a nice header.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBackButton(viewModel),
                const Text(
                  '粘贴作业',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(width: 40), // Balance left button width
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(TextInputViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.onCancel,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.slate100,
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.chevronLeft, color: AppColors.slate600, size: 20),
      ),
    );
  }

  Widget _buildExtractButton(TextInputViewModel viewModel) {
    final bool isEmpty = viewModel.textController.text.trim().isEmpty;
    final bool isLoading = viewModel.isExtracting;
    final bool isDisabled = isEmpty || isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : () => viewModel.extractWords(viewModel.textController.text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64, // py-4 approx with text
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.slate100 : AppColors.slate900,
          borderRadius: BorderRadius.circular(20), // rounded-2xl
          boxShadow: isDisabled ? [] : [
            const BoxShadow(
              color: AppColors.slate200, // shadow-slate-200
              blurRadius: 10,
              offset: Offset(0, 4), // shadow-lg approx
            )
          ],
        ),
        child: Center(
          child: isLoading 
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(color: AppColors.slate400, strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '正在提取生词...',
                    style: TextStyle(color: AppColors.slate400, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.sparkles, color: isDisabled ? AppColors.slate400 : Colors.white, size: 20),
                  const SizedBox(width: 8), // gap-2
                  Text(
                    'AI 智能提取',
                    style: TextStyle(
                      color: isDisabled ? AppColors.slate400 : Colors.white,
                      fontSize: 18, // text-lg
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  @override
  TextInputViewModel viewModelBuilder(BuildContext context) => TextInputViewModel();
}
