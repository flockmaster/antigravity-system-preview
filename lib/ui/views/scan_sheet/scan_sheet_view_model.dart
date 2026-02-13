import 'dart:io';
import 'package:camera/camera.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/base/baic_base_view_model.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/dictation_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/models/dictation_session.dart';
import '../../../core/utils/app_logger.dart';
import 'package:image/image.dart' as img;

/// 听写单扫描与批改视图模型
class ScanSheetViewModel extends BaicBaseViewModel {
  final _aiService = locator<AiService>();
  final _dictationService = locator<DictationService>();
  final _dbService = locator<DatabaseService>();

  CameraController? _cameraController;
  /// 相机控制器
  CameraController? get cameraController => _cameraController;

  bool _processing = false;
  /// 是否正在进行 AI 批改
  bool get processing => _processing;

  /// 初始化相机
  Future<void> init() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      notifyListeners();
    } catch (e) {
      AppLogger.e('相机初始化失败', error: e);
      await dialogService.showDialog(
        title: '相机错误',
        description: '无法初始化相机，请检查权限和设备状态。',
        buttonTitle: '确定',
      );
    }
  }



  /// 拍照并进行 AI 自动批改
  Future<void> scanAndGrade() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _processing = true;
    notifyListeners();

    try {
      // 1. 拍摄听写单照片
      final XFile photo = await _cameraController!.takePicture();
      File imageFile = File(photo.path);

      // 1.5 图片压缩优化 (Resize to max 1024px, JPEG 85%)
      try {
        final rawImage = img.decodeImage(await imageFile.readAsBytes());
        if (rawImage != null) {
          // Resize if too large
          if (rawImage.width > 1024 || rawImage.height > 1024) {
             final resized = img.copyResize(
               rawImage, 
               width: rawImage.width > rawImage.height ? 1024 : null,
               height: rawImage.height >= rawImage.width ? 1024 : null,
               maintainAspect: true,
             );
             // Encode to JPG with 85% quality
             final compressedBytes = img.encodeJpg(resized, quality: 85);
             
             // Overwrite or create new temp file
             final newPath = '${imageFile.path}_compressed.jpg';
             imageFile = await File(newPath).writeAsBytes(compressedBytes);
          } else {
             // Even if size is okay, compress quality to save bandwidth
             final compressedBytes = img.encodeJpg(rawImage, quality: 85);
             final newPath = '${imageFile.path}_optimized.jpg';
             imageFile = await File(newPath).writeAsBytes(compressedBytes);
          }
        }
      } catch (e) {
        AppLogger.w('图片压缩失败，将使用原图', error: e);
        // Continue with original image if compression fails
      }

      // 2. 调用 AI 服务进行批改
      final expectedWords = _dictationService.currentWords;
      final mistakes = await _aiService.gradeDictation(imageFile, expectedWords);

      // 3. 计算成绩
      final total = expectedWords.length;
      final correctCount = mistakes.where((m) => m.isCorrect).length;
      final score = ((correctCount / total) * 100).round();

      // 4. 生成听写会话
      final session = DictationSession(
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        mode: _dictationService.currentMode,
        date: DateTime.now().toString().split('.').first,
        words: expectedWords,
      );

      final result = SessionResult(
        sessionId: session.sessionId,
        score: score,
        total: total,
        mistakes: mistakes,
      );

      // 5. 保存到数据库
      await _dbService.saveSession(session, result);

      // 6. 更新服务中的结果
      _dictationService.setResult(result);

      // 7. 跳转到结果页
      navigationService.navigateToResultView();

    } catch (e) {
      AppLogger.e('批改错误', error: e);
      await dialogService.showDialog(
        title: 'AI 批改失败',
        description: '遇到了一些问题，无法完成自动批改。\n请确保网络畅通，且拍摄的字迹清晰。\n\n技术详情: ${e.toString()}',
        buttonTitle: '知道了',
      );
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
