import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:stacked/stacked.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'scan_sheet_view_model.dart';

class ScanSheetView extends StackedView<ScanSheetViewModel> {
  const ScanSheetView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ScanSheetViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview
          _buildCameraPreview(viewModel),

          // 2. Overlay (Semi-transparent black with cutout)
          const _ScannerOverlay(),

          // 3. Scanning Animation (Line moving up and down)
          if (!viewModel.processing)
             const _ScannerLine(),

          // 4. Content (Header & Footer)
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header Prompt
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    '请将听写单放入对焦框内',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Footer Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hint Text
                      const Text(
                        '保持手机平稳',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Shutter Button
                      GestureDetector(
                        onTap: viewModel.processing ? null : viewModel.scanAndGrade,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                spreadRadius: 2
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 5. Processing / Loading Overlay
           if (viewModel.processing)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                         color: AppColors.violet500,
                         strokeWidth: 4,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'AI 正在批改中...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(ScanSheetViewModel viewModel) {
    if (viewModel.cameraController == null || !viewModel.cameraController!.value.isInitialized) {
      return Container(color: Colors.black);
    }
    return SizedBox.expand(
      child: CameraPreview(viewModel.cameraController!),
    );
  }

  @override
  void onViewModelReady(ScanSheetViewModel viewModel) {
    viewModel.init();
  }

  @override
  ScanSheetViewModel viewModelBuilder(BuildContext context) => ScanSheetViewModel();
}

/// Draws a semi-transparent background with a rounded rectangular cutout
class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        Colors.black54,
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.width * 0.85 * 1.414, // A4 ratio approx
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated scanning line
class _ScannerLine extends StatefulWidget {
  const _ScannerLine();

  @override
  State<_ScannerLine> createState() => _ScannerLineState();
}

class _ScannerLineState extends State<_ScannerLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanAreaWidth = MediaQuery.of(context).size.width * 0.85;
    final scanAreaHeight = scanAreaWidth * 1.414;

    return Center(
      child: SizedBox(
        width: scanAreaWidth,
        height: scanAreaHeight,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: scanAreaHeight * _controller.value,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.violet500.withValues(alpha: 0),
                          AppColors.violet500,
                          AppColors.violet500.withValues(alpha: 0),
                        ],
                      ),
                      boxShadow: [
                         BoxShadow(
                           color: AppColors.violet500.withValues(alpha: 0.5),
                           blurRadius: 10,
                           spreadRadius: 2,
                         )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
