import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import '../../widgets/breathing_orb.dart';
import '../../widgets/baic_shake_widget.dart';
import 'dictation_view_model.dart';
import '../../../core/models/dictation_session.dart';

class DictationView extends StackedView<DictationViewModel> {
  const DictationView({super.key});

  @override
  Widget builder(
    BuildContext context,
    DictationViewModel viewModel,
    Widget? child,
  ) {
    if (!viewModel.hasQueue) {
      return const Scaffold(body: Center(child: Text("加载中...")));
    }
    
    // Theme Configuration (DYNAMIC based on current item)
    Color themeColor;
    Color themeLightColor;
    Color themeGlowColor;

    switch (viewModel.currentItemMode) {
      case DictationMode.modeA:
        themeColor = AppColors.violet600;
        themeLightColor = AppColors.violet100;
        themeGlowColor = AppColors.violet500;
        break;
      case DictationMode.modeB:
        themeColor = AppColors.orange500;
        themeLightColor = AppColors.orange100;
        themeGlowColor = AppColors.orange500;
        break;
      case DictationMode.modeC:
        themeColor = AppColors.emerald500;
        themeLightColor = AppColors.emerald100;
        themeGlowColor = AppColors.emerald500;
        break;
      case DictationMode.modeMixed:
      case DictationMode.mistakeCrusher:
      case DictationMode.smartReview:
      case DictationMode.customSelection:
        // Use a neutral or gradient theme like modeA but distinct
        themeColor = AppColors.slate900;
        themeLightColor = AppColors.slate100;
        themeGlowColor = AppColors.slate500;
        break;
    }

    // Calculate progress percentage
    final double progress = (viewModel.currentIndex + 1) / viewModel.queue.length;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Click anywhere to close keyboard
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.surface, // bg-white
        body: Stack(
          children: [
            Column(
              children: [
                 // Top Progress Bar
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: 6,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(color: AppColors.slate100), // bg-slate-100
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 300),
                          widthFactor: progress,
                          child: Container(color: themeColor),
                        ),
                      ],
                    ),
                  ),
                ),

                // Header Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '题目 ${viewModel.currentIndex + 1} / ${viewModel.queue.length}',
                        style: const TextStyle(
                          color: AppColors.slate400,
                          fontSize: 12, // text-xs
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2, // tracking-wider
                        ),
                      ),
                      
                      // Show Current Mode Label (Useful for Mixed Mode)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: themeLightColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          viewModel.getModeLabel(),
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Area
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Spacing
                              const SizedBox(height: 20),
                              
                              // Specific logic for Mode B (Chinese meaning shown)
                              if (viewModel.currentItemMode == DictationMode.modeB) ...[
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: Text(
                                    viewModel.currentWord.meaningForDictation,
                                    key: ValueKey(viewModel.currentItem.id),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 30, // text-3xl
                                      fontWeight: FontWeight.w900, // font-black
                                      color: AppColors.slate900,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32), // mb-8
                              ],

                              // Breathing Orb & Replay
                              GestureDetector(
                                onTap: viewModel.isSpeaking ? null : viewModel.init, // Replay
                                child: Column(
                                  children: [
                                    BreathingOrb(isActive: viewModel.isSpeaking, color: themeColor),
                                    if (viewModel.currentItemMode != DictationMode.modeB) ...[
                                       const SizedBox(height: 24),
                                       Text(
                                         viewModel.isSpeaking ? '正在朗读...' : '点击重读',
                                         style: TextStyle(
                                           color: viewModel.isSpeaking ? themeColor : AppColors.slate300,
                                           fontWeight: FontWeight.bold,
                                           fontSize: 14,
                                         ),
                                       ),
                                    ]
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 48), // mb-12

                              // Digital Input Box
                              if (viewModel.isDigital)
                                 Stack(
                                   alignment: Alignment.center,
                                   children: [
                                     // Glow Background
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: themeLightColor.withValues(alpha: 0.5), 
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                 color: themeGlowColor.withValues(alpha: 0.1),
                                                 blurRadius: 30,
                                                 spreadRadius: 0,
                                              )
                                            ]
                                          ),
                                        ), 
                                      ),
                                     
                                     // Input Field
                                     BaicShakeWidget(
                                       isShake: viewModel.isShake,
                                       child: Container(
                                         height: 80,
                                         decoration: BoxDecoration(
                                           color: Colors.white,
                                           borderRadius: BorderRadius.circular(24),
                                           border: Border.all(
                                             color: AppColors.slate100,
                                             width: 2,
                                           ),
                                            boxShadow: [
                                               BoxShadow(
                                                 color: Colors.black.withValues(alpha: 0.03),
                                                 blurRadius: 20,
                                                 offset: const Offset(0, 4),
                                               )
                                            ]
                                         ),
                                         alignment: Alignment.center,
                                         padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: TextField(
                                            controller: viewModel.inputController,
                                            focusNode: viewModel.inputFocusNode,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 24, // text-2xl
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.slate900,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: viewModel.currentItemMode == DictationMode.modeC ? '输入中文释义...' : '输入英文单词...',
                                              hintStyle: const TextStyle(color: AppColors.slate300),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onChanged: viewModel.updateInput,
                                            onSubmitted: (_) => viewModel.next(),
                                            textInputAction: TextInputAction.next,
                                            autocorrect: true, // 强制开启以支持各类输入法（IME），避免 iOS 等设备上的输入卡顿或无效
                                            enableSuggestions: true, // 强制开启以支持输入法联想
                                            keyboardType: TextInputType.text, 
                                            maxLines: 1,
                                            textCapitalization: TextCapitalization.none,
                                          ),
                                        ),
                                     ),
                                   ],
                                 ),
                              
                              // Bottom padding to avoid keyboard covering content fully
                              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Action (Hide when keyboard is open to save space if needed, or keep it)
                // Keeping it but maybe shrink padding?
                if (MediaQuery.of(context).viewInsets.bottom == 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 20, 32, 48),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: viewModel.next,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 64,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.slate900,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                 BoxShadow(
                                   color: AppColors.slate200,
                                   blurRadius: 20,
                                   offset: Offset(0, 10),
                                 )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  viewModel.isLastItem ? '完成' : '下一个',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(width: 8),
                                 const Icon(LucideIcons.arrowRight, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                        
                        // Bottom Replay Button (Fade out when speaking)
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          opacity: viewModel.isSpeaking ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: viewModel.init,
                             child: const Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Icon(LucideIcons.rotateCcw, size: 12, color: AppColors.slate400),
                                 SizedBox(width: 6),
                                 Text(
                                   '重读一遍',
                                   style: TextStyle(
                                     color: AppColors.slate400,
                                     fontSize: 12,
                                     fontWeight: FontWeight.bold,
                                     letterSpacing: 1.2,
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
            
            // Loading Overlay
            if (viewModel.isAnalyzing)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          color: themeColor,
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'AI 老师正在批改...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(DictationViewModel viewModel) {
    viewModel.init();
  }

  @override
  DictationViewModel viewModelBuilder(BuildContext context) => DictationViewModel();
}
