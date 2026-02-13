import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/app.locator.dart';
import '../../../core/base/baic_base_view_model.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/edge_tts/edge_tts.dart';

/// TTS 设置页面 ViewModel
/// 
/// 管理 TTS 引擎选择、Edge TTS 口音和语音包设置
class TtsSettingsViewModel extends BaicBaseViewModel {
  final _ttsService = locator<TtsService>();
  
  String _currentSource = 'edge'; // 默认使用 Edge TTS
  String get currentSource => _currentSource;
  
  /// 当前英语口音
  EnglishAccent get currentAccent => _ttsService.currentEnglishAccent;
  
  /// 当前英文语音ID
  String get currentEnglishVoice => _ttsService.currentEnglishVoice;
  
  /// 当前中文语音ID
  String get currentChineseVoice => _ttsService.currentChineseVoice;
  
  /// 获取当前口音可用的英文语音列表
  List<VoiceInfo> get availableEnglishVoices => _ttsService.getAvailableEnglishVoices();
  
  /// 获取可用的中文语音列表
  List<VoiceInfo> get availableChineseVoices => _ttsService.getAvailableChineseVoices();

  TtsSettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSource = prefs.getString('tts_source') ?? 'edge'; // 默认 Edge
    notifyListeners();
  }

  /// 设置 TTS 引擎
  Future<void> setSource(String source) async {
    _currentSource = source;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_source', source);
    
    // 通知 TtsService 切换引擎
    _ttsService.updateEngine(source);
    
    notifyListeners();
  }
  
  /// 设置英语口音
  Future<void> setAccent(EnglishAccent accent) async {
    await _ttsService.setEnglishAccent(accent);
    notifyListeners();
  }
  
  /// 设置英文语音
  Future<void> setEnglishVoice(String voice) async {
    await _ttsService.setEnglishVoice(voice);
    notifyListeners();
  }
  
  /// 设置中文语音
  Future<void> setChineseVoice(String voice) async {
    await _ttsService.setChineseVoice(voice);
    notifyListeners();
  }

  /// 测试当前语音
  Future<void> testVoice() async {
    await _ttsService.speakEnglish("Hello, this is a test of the current voice synthesis engine.");
  }
  
  /// 试听指定英文语音
  Future<void> previewEnglishVoice(String voice) async {
    // 设置语音并进行试听（试听后语音会被保留）
    await _ttsService.setEnglishVoice(voice);
    await _ttsService.speakEnglish("Hello, this is a voice preview.");
    notifyListeners();
  }
  
  /// 试听指定中文语音
  Future<void> previewChineseVoice(String voice) async {
    // 设置语音并进行试听（试听后语音会被保留）
    await _ttsService.setChineseVoice(voice);
    await _ttsService.speakChinese("你好，这是语音试听。");
    notifyListeners();
  }
}
