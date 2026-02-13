import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/base/baic_base_view_model.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/dictation_service.dart';
import '../../../core/utils/app_logger.dart';

/// 扫描课本视图模型
/// 
/// 负责管理相机生命周期、切换扫描模式以及调用 AI 服务进行图像处理。
class ScanBookViewModel extends BaicBaseViewModel {
  final _aiService = locator<AiService>();
  final _dictationService = locator<DictationService>();

  CameraController? _cameraController;
  /// 相机控制器
  CameraController? get cameraController => _cameraController;

  bool _scanning = false;
  /// 是否正在进行 AI 分析
  bool get scanning => _scanning;

  String _scanMode = 'smart';
  /// 当前扫描模式 (smart, circle, check, all)
  String get scanMode => _scanMode;

  final ImagePicker _picker = ImagePicker();

  int _cameraIndex = 0;
  List<CameraDescription> _cameras = [];

  /// 初始化相机
  Future<void> init() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    await _initCamera(_cameras[_cameraIndex]);
  }

  Future<void> _initCamera(CameraDescription description) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      notifyListeners();
    } catch (e) {
      AppLogger.e('相机初始化失败', error: e);
      dialogService.showDialog(title: '相机错误', description: '无法启动相机: $e');
    }
  }

  /// 切换前后摄像头
  Future<void> toggleCamera() async {
    if (_cameras.length < 2) return;
    
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _initCamera(_cameras[_cameraIndex]);
  }

  /// 从相册选择图片并分析
  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    _scanning = true;
    notifyListeners();

    try {
      final File imageFile = File(image.path);
      await _analyzeImage(imageFile);
    } catch (e) {
      _handleError(e);
    } finally {
      _scanning = false;
      notifyListeners();
    }
  }

  /// 封装识别逻辑
  Future<void> _analyzeImage(File imageFile) async {
    final words = await _aiService.extractWordsFromImage(imageFile, mode: _scanMode);

    if (words.isNotEmpty) {
      _dictationService.setWords(words);
      navigationService.navigateToWordListView();
    } else {
      await dialogService.showDialog(
        title: '未识别到单词',
        description: 'AI 未能从图片中提取到符合当前模式的单词。\n请确保图片清晰，或尝试切换到"整页"模式。',
        buttonTitle: '好的',
      );
    }
  }

  void _handleError(Object e) {
    AppLogger.e('图像识别错误', error: e);
    dialogService.showDialog(
      title: '识别出错',
      description: '处理图片时发生错误：$e\n请检查网络连接或稍后重试。',
      buttonTitle: '好的',
    );
  }

  /// 设置扫描模式
  void setScanMode(String mode) {
    _scanMode = mode;
    notifyListeners();
  }

  /// 拍照并分析
  Future<void> captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _scanning = true;
    notifyListeners();

    try {
      // 1. 拍摄照片
      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      // 2. 调用识别
      await _analyzeImage(imageFile);
    } catch (e) {
      _handleError(e);
    } finally {
      _scanning = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

