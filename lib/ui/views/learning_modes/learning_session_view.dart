import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/learning_model.dart';
import '../../../../core/models/word.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'learning_session_view_model.dart';
import '../common/game_feedback_widgets.dart';
import '../common/pet_mood_display.dart';

// Import Sub-Views
import 'preview/preview_view.dart';
import 'recognition/recognition_view.dart';
import 'construction/construction_view.dart';
import 'recall/recall_view.dart';
import 'read_aloud/read_aloud_view.dart';
import 'dictation/dictation_view.dart';
import 'dictation/dictation_view.dart';
// import 'summary/summary_view.dart'; // Removed as we navigate to ResultView now


class LearningSessionView extends StackedView<LearningSessionViewModel> {
  final String? source;
  final List<Word>? words;
  
  const LearningSessionView({super.key, this.words, this.source});

  @override
  LearningSessionViewModel viewModelBuilder(BuildContext context) =>
      LearningSessionViewModel();

  @override
  void onViewModelReady(LearningSessionViewModel viewModel) => viewModel.init(
    words: words,
    source: source,
  );

  @override
  Widget builder(
    BuildContext context,
    LearningSessionViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stage = viewModel.session!.currentStage;
    
    // Only require currentWord for non-summary stages
    if (stage != LearningStage.summary && viewModel.currentWord == null) {
       return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // safe to access word if not summary, otherwise it might be null
    final word = viewModel.currentWord ?? const Word(
        id: 'dummy', 
        word: '', 
        meaningFull: '', 
        meaningForDictation: '', 
        phonetic: '', 
        sentence: ''
    ); // Dummy for summary stage if needed by KeyedSubView signature

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(context, viewModel, stage),
  
                // Main Content Area
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubView(
                      key: ValueKey('${stage.name}_${word.id}'), // Unique key triggers animation
                      stage: stage,
                      word: word,
                      onNext: viewModel.onNext,
                      onError: viewModel.onError,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Combo Toast Layer (T1.5: 实时 Combo 轻量提示)
          if (viewModel.showComboToast)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)], // 火焰渐变
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.flame, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Combo x${viewModel.comboCount}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '+1',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Confetti Layer
          if (viewModel.showConfetti)
             ConfettiOverlay(shouldPlay: viewModel.showConfetti),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, LearningSessionViewModel viewModel, LearningStage stage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.x, color: AppColors.slate400),
                onPressed: viewModel.onExit,
              ),
              Expanded(
                child: Text(
                  stage.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
              ),
              // Game Agent / Pet
              PetMoodDisplay(mood: viewModel.currentMood, size: 36),
            ],
          ),
          const SizedBox(height: 8),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: viewModel.progress,
              backgroundColor: AppColors.slate100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green500),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class KeyedSubView extends StatelessWidget {
  final LearningStage stage;
  final Word word;
  final VoidCallback onNext;
  final Function([String?]) onError; // Updated signature

  const KeyedSubView({
    super.key,
    required this.stage,
    required this.word,
    required this.onNext,
    required this.onError,
  });


  Widget _buildStageContent(BuildContext context) {
    switch (stage) {
      case LearningStage.preview:
        return PreviewView(word: word, onNext: onNext);
      case LearningStage.recognition:
        return RecognitionView(
          word: word, 
          onNext: onNext,
          onError: () => onError(),  // 这里使用 onError，由 RecognitionViewModel 内部处理 requeue
        );
      case LearningStage.readAloud:  // 第2.5关：大声朗读
        return ReadAloudView(
          word: word, 
          onNext: onNext,
          onError: onError,
        );
      case LearningStage.recall:  // 第3关：填空回想
        return RecallView(
          word: word, 
          onNext: onNext,
          onError: () => onError(),
        );
      case LearningStage.construction:  // 第4关：拼写重组
        return ConstructionView(
          word: word,
          onNext: onNext,
          onError: (reason) => onError(reason),
        );
      case LearningStage.dictation:
        return DictationView(
          word: word,
          onNext: onNext,
          onError: (reason) => onError(reason),
        );
      case LearningStage.summary:
        // Navigating to result view...
        return const Center(child: CircularProgressIndicator());
    }
  }
  
  @override
  Widget build(BuildContext context) {
      return _buildStageContent(context);
  }
}
