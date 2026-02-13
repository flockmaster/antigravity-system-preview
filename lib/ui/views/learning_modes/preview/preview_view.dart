import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math' as math;
import '../../../../core/models/word.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'preview_view_model.dart';

class PreviewView extends StackedView<PreviewViewModel> {
  final Word word;
  final VoidCallback onNext;

  const PreviewView({
    super.key,
    required this.word,
    required this.onNext,
  });

  @override
  PreviewViewModel viewModelBuilder(BuildContext context) =>
      PreviewViewModel(word: word, onNext: onNext);

  @override
  void onViewModelReady(PreviewViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    PreviewViewModel viewModel,
    Widget? child,
  ) {
    return Column(
      children: [
        // 3D Card Area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Center(
              child: _buildPerspectiveCard(context, viewModel),
            ),
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.only(left: 32, right: 32, bottom: 48, top: 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: viewModel.next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slate900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 4,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('下一步', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(LucideIcons.chevronRight, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3D Card Logic (Reuse from FlashCardView) ---

  Widget _buildPerspectiveCard(BuildContext context, PreviewViewModel viewModel) {
    final targetAngle = viewModel.isFlipped ? math.pi : 0.0;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: targetAngle),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, angle, child) {
        final isBackVisible = angle >= math.pi / 2;
        var transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);
          
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: isBackVisible 
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: GestureDetector(
                  onTap: viewModel.flipCard,
                  child: _buildCardBack(context, viewModel),
                ),
              )
            : GestureDetector(
                onTap: viewModel.flipCard,
                child: _buildCardFront(context, viewModel),
              ),
        );
      },
    );
  }

  Widget _buildCardFront(BuildContext context, PreviewViewModel viewModel) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 360, maxHeight: 520),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate200.withValues(alpha: 0.6),
            blurRadius: 40,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.indigo50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.indigo100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.eye, size: 12, color: AppColors.indigo500),
                SizedBox(width: 6),
                Text(
                  'PREVIEW',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.indigo500, letterSpacing: 0.5),
                )
              ],
            ),
          ),
          
          const Spacer(),
          
          Text(
            word.word,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.slate900, height: 1.1, letterSpacing: -1.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
             onTap: () => viewModel.speakWord(),
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               decoration: BoxDecoration(
                 color: AppColors.slate100,
                 borderRadius: BorderRadius.circular(20),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(LucideIcons.volume2, size: 16, color: AppColors.slate500),
                   const SizedBox(width: 8),
                   Text(
                      word.phonetic,
                      style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate500),
                   ),
                 ],
               ),
             ),
          ),

          const Spacer(),

          // Hint
          const Text(
            '点击翻转查看记忆法',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate300, letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, PreviewViewModel viewModel) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 360, maxHeight: 520),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)], // Violet Gradient
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet500.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Meaning
          Text(
            word.meaningForDictation,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Mnemonic Card
          if (viewModel.displayMnemonic.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.lightbulb, color: AppColors.amber300, size: 16),
                      const SizedBox(width: 8),
                      const Text('记忆法 (Mnemonic)', style: TextStyle(color: AppColors.amber300, fontSize: 12, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // Regenerate Button
                      GestureDetector(
                        onTap: viewModel.isRegenerating ? null : viewModel.regenerateMnemonicAction,
                        child: viewModel.isRegenerating 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.amber300))
                          : const Icon(LucideIcons.refreshCw, color: AppColors.amber300, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.displayMnemonic,
                    style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else 
            // Empty State for Mnemonic
             GestureDetector(
               onTap: viewModel.regenerateMnemonicAction,
               child: Container(
                 padding: const EdgeInsets.symmetric(vertical: 24),
                 alignment: Alignment.center,
                 decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20),
                 ),
                 child: viewModel.isRegenerating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Column(
                        children: [
                          Icon(LucideIcons.wand2, color: Colors.white, size: 24),
                          SizedBox(height: 8),
                          Text('点击生成速记助记符', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
               ),
             ),
          
          if (word.sentence.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                word.sentence,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 14, 
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  fontFamily: 'Roboto'
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const Spacer(),

          // Shadowing Widget
          _buildShadowingWidget(viewModel),
        ],
      ),
    );
  }

  Widget _buildShadowingWidget(PreviewViewModel viewModel) {
    // 使用 GestureDetector 包裹，设置空的 onTap 来阻止事件冒泡到卡片翻转
    return GestureDetector(
      onTap: () {}, // 吞掉点击事件，不让它冒泡到卡片
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(' 跟读测验 (Oral Practice) ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slate400)),
          const SizedBox(height: 16),
          if (viewModel.isMatched)
             Container(
               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
               decoration: BoxDecoration(color: AppColors.green100, borderRadius: BorderRadius.circular(20)),
               child: const Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(LucideIcons.checkCircle, color: AppColors.green600, size: 16),
                   SizedBox(width: 8),
                   Text('Pronunciation Correct!', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.bold)),
                 ],
               ),
             )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Speak Button (Center)
                Listener(
                  onPointerDown: (_) => viewModel.startListening(),
                  onPointerUp: (_) => viewModel.stopListening(),
                  onPointerCancel: (_) => viewModel.stopListening(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: viewModel.isListening ? AppColors.red500 : AppColors.indigo500,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (viewModel.isListening ? AppColors.red500 : AppColors.indigo500).withValues(alpha: 0.4),
                          blurRadius: viewModel.isListening ? 20 : 10,
                          spreadRadius: viewModel.isListening ? 5 : 0,
                        )
                      ],
                    ),
                    child: Icon(
                      viewModel.isListening ? LucideIcons.mic : LucideIcons.mic,
                      color: Colors.white, size: 32,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (viewModel.recognizedText.isNotEmpty)
             Text(
                'You said: "${viewModel.recognizedText}"',
                style: const TextStyle(fontSize: 14, color: AppColors.slate600, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
             ),
          const SizedBox(height: 8),
          Text(
            viewModel.isMatched 
                ? 'Great Job!' 
                : (viewModel.isListening ? 'Listening...' : 'Hold to Speak'),
            style: TextStyle(
              fontSize: 12, 
              color: viewModel.isMatched ? AppColors.green600 : AppColors.slate400,
              fontWeight: viewModel.isMatched ? FontWeight.bold : FontWeight.normal
            ),
          )
        ],
      ),
      ),
    );
  }
}
