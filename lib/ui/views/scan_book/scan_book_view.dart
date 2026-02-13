import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'scan_book_view_model.dart';

class ScanBookView extends StackedView<ScanBookViewModel> {
  const ScanBookView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ScanBookViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 相机预览
          _buildCameraPreview(viewModel),

          // 2. 扫描框装饰
          _buildScanOverlay(),

          // 3. 底部控制栏
          _buildBottomControls(context, viewModel),

          // 4. 分析中遮罩
          if (viewModel.scanning) _buildScanningOverlay(),
          
          // 5. 顶部返回按钮
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(ScanBookViewModel viewModel) {
    if (viewModel.cameraController == null || !viewModel.cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return SizedBox.expand(
      child: CameraPreview(viewModel.cameraController!),
    );
  }

  Widget _buildScanOverlay() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              _buildCorner(0, 0, 1, 1), // Top left
              _buildCorner(null, 0, 0, 1), // Top right
              _buildCorner(0, null, 1, 0), // Bottom left
              _buildCorner(null, null, 0, 0), // Bottom right
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(double? left, double? top, double? right, double? bottom) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top == 0 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            left: left == 0 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            right: right == 0 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            bottom: bottom == 0 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: left == 0 && top == 0 ? const Radius.circular(12) : Radius.zero,
            topRight: right == 0 && top == 0 ? const Radius.circular(12) : Radius.zero,
            bottomLeft: left == 0 && bottom == 0 ? const Radius.circular(12) : Radius.zero,
            bottomRight: right == 0 && bottom == 0 ? const Radius.circular(12) : Radius.zero,
          ),
        ),
      ),
    );
  }


  Widget _buildBottomControls(BuildContext context, ScanBookViewModel viewModel) {
    return Positioned(
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: const EdgeInsets.only(top: 40, bottom: 40),

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // 模式切换器
            _buildModeSelector(viewModel),
            const SizedBox(height: 30),
            // 快门与辅助按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSideButton(LucideIcons.image, viewModel.pickImageFromGallery),
                  _buildShutterButton(viewModel),
                  _buildSideButton(LucideIcons.rotateCcw, viewModel.toggleCamera),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(ScanBookViewModel viewModel) {
    final modes = [
      {'id': 'smart', 'label': '智能', 'icon': LucideIcons.scanLine},
      {'id': 'circle', 'label': '圈画', 'icon': LucideIcons.circle},
      {'id': 'check', 'label': '打钩', 'icon': LucideIcons.check},
      {'id': 'all', 'label': '整页', 'icon': LucideIcons.bookOpen},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modes.map((m) {
          final isSelected = viewModel.scanMode == m['id'];
          return GestureDetector(
            onTap: () => viewModel.setScanMode(m['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Icon(
                    m['icon'] as IconData,
                    size: 14,
                    color: isSelected ? Colors.black : Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSideButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _buildShutterButton(ScanBookViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.scanning ? null : viewModel.captureAndAnalyze,
      child: AnimatedScale(
        scale: viewModel.scanning ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.white54, blurRadius: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: AppColors.violet600,
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 30),
            Text(
              '正在分析...',
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
    );
  }

  @override
  void onViewModelReady(ScanBookViewModel viewModel) {
    viewModel.init();
  }

  @override
  ScanBookViewModel viewModelBuilder(BuildContext context) => ScanBookViewModel();
}
