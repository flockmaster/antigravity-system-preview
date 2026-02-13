import 'tts/i_tts_service.dart';
import 'tts/system_tts_service.dart';
import 'xfyun_tts_engine.dart';
import 'edge_tts/edge_tts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 导入 SharedPreferences
import 'package:flutter/foundation.dart'; // 导入 debugPrint

/// TTS 引擎类型
enum TtsEngineType {
  /// 系统 TTS（免费，质量一般）
  system,
  /// 科大讯飞 TTS（收费，高质量）
  xfyun,
  /// 微软 Edge TTS（免费，高质量）- 推荐！
  edge,
}

/// 语音朗读服务类
/// 
/// 负责单词、释义和例句的语音播放。
/// 
/// 支持三种 TTS 引擎：
/// - `system`: 系统自带 TTS（免费，质量一般）
/// - `xfyun`: 科大讯飞超拟人（收费，高质量）
/// - `edge`: 微软 Edge TTS（免费，高质量）- 推荐！
class TtsService {
  final ITtsService _systemTts = SystemTtsService();
  final XfyunTtsEngine _xfyunEngine = XfyunTtsEngine();
  final EdgeTtsEngine _edgeEngine = EdgeTtsEngine();
  
  String _currentSource = 'edge'; // 默认使用 Edge TTS
  bool _isInitialized = false;
  bool _isEnglishAvailable = false;
  bool _isChineseAvailable = false;
  
  TtsService() {
    _loadSettingsAndInit();
  }

  Future<void> _loadSettingsAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSource = prefs.getString('tts_source') ?? 'edge'; // 默认 Edge
    
    // 加载 Edge TTS 的口音和语音设置
    final accentStr = prefs.getString('edge_english_accent') ?? 'american';
    final accent = accentStr == 'british' ? EnglishAccent.british : EnglishAccent.american;
    _edgeEngine.setAccent(accent);
    
    // 加载保存的英文语音（如果有）
    final savedEnglishVoice = prefs.getString('edge_english_voice');
    if (savedEnglishVoice != null && savedEnglishVoice.isNotEmpty) {
      _edgeEngine.setEnglishVoice(savedEnglishVoice);
    }
    
    // 加载保存的中文语音（如果有）
    final savedChineseVoice = prefs.getString('edge_chinese_voice');
    if (savedChineseVoice != null && savedChineseVoice.isNotEmpty) {
      _edgeEngine.setChineseVoice(savedChineseVoice);
    }
    
    await _initTts();
  }

  /// 更新引擎
  void updateEngine(String source) {
    _currentSource = source;
    debugPrint("TTS 切换引擎: $source");
  }
  
  /// 获取当前引擎类型
  TtsEngineType get currentEngineType {
    switch (_currentSource) {
      case 'xfyun':
        return TtsEngineType.xfyun;
      case 'edge':
        return TtsEngineType.edge;
      default:
        return TtsEngineType.system;
    }
  }
  
  // ========== Edge TTS 口音和语音设置 ==========
  
  /// 获取当前英语口音
  EnglishAccent get currentEnglishAccent => _edgeEngine.currentAccent;
  
  /// 获取当前英文语音ID
  String get currentEnglishVoice => _edgeEngine.currentEnglishVoice;
  
  /// 获取当前中文语音ID
  String get currentChineseVoice => _edgeEngine.currentChineseVoice;
  
  /// 设置英语口音（会自动切换到该口音的默认语音）
  Future<void> setEnglishAccent(EnglishAccent accent) async {
    _edgeEngine.setAccent(accent);
    
    // 保存到 SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('edge_english_accent', accent == EnglishAccent.british ? 'british' : 'american');
    await prefs.setString('edge_english_voice', _edgeEngine.currentEnglishVoice);
  }
  
  /// 设置英文语音
  Future<void> setEnglishVoice(String voice) async {
    _edgeEngine.setEnglishVoice(voice);
    
    // 保存到 SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('edge_english_voice', voice);
  }
  
  /// 设置中文语音
  Future<void> setChineseVoice(String voice) async {
    _edgeEngine.setChineseVoice(voice);
    
    // 保存到 SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('edge_chinese_voice', voice);
  }
  
  /// 获取当前口音可用的英文语音列表
  List<VoiceInfo> getAvailableEnglishVoices() {
    return _edgeEngine.getAvailableEnglishVoices();
  }
  
  /// 获取可用的中文语音列表
  List<VoiceInfo> getAvailableChineseVoices() {
    return _edgeEngine.getAvailableChineseVoices();
  }

  /// 初始化 TTS 配置
  Future<void> _initTts() async {
    try {
      // 系统 TTS 是自动初始化的，但如果需要，我们可以这里检查语言。
      
      // 检查语言可用性 (Delegated to SystemTtsService)
      _isEnglishAvailable = await _checkLanguageAvailable("en-US");
      _isChineseAvailable = await _checkLanguageAvailable("zh-CN");
      
      debugPrint("TTS 英语可用性: $_isEnglishAvailable");
      debugPrint("TTS 中文可用性: $_isChineseAvailable");
      
      _isInitialized = true;
      debugPrint("TTS 服务初始化成功");
    } catch (e) {
      debugPrint("TTS 初始化错误: $e");
      _isInitialized = false;
    }
  }
  
  /// 检查语言是否可用
  Future<bool> _checkLanguageAvailable(String language) async {
    try {
      return await _systemTts.isLanguageAvailable(language);
    } catch (e) {
      debugPrint("TTS Language check error for $language: $e");
      return false;
    }
  }
  
  /// 确保 TTS 已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initTts();
    }
  }

  /// 朗读英语
  Future<void> speakEnglish(String text) async {
    // 使用科大讯飞
    if (_currentSource == 'xfyun') {
      await _xfyunEngine.speak(text);
      return;
    }
    
    // 使用 Edge TTS（推荐）
    if (_currentSource == 'edge') {
      try {
        await _edgeEngine.speakEnglish(text);
        debugPrint("Edge TTS 朗读英语: $text");
      } catch (e) {
        debugPrint("Edge TTS speakEnglish 错误: $e, 降级到系统 TTS");
        // 降级到系统 TTS
        await _speakWithSystemTts(text, "en-US");
      }
      return;
    }

    // 使用系统 TTS
    await _speakWithSystemTts(text, "en-US");
  }
  
  /// 使用系统 TTS 朗读
  Future<void> _speakWithSystemTts(String text, String language) async {
    await _ensureInitialized();
    
    try {
      await _systemTts.speak(text, language: language);
      debugPrint("系统 TTS speak ($language): $text");
    } catch (e) {
      debugPrint("系统 TTS 错误 ($language): $e");
    }
  }

  /// 朗读中文
  Future<void> speakChinese(String text) async {
    // 使用科大讯飞
    if (_currentSource == 'xfyun') {
      await _xfyunEngine.speak(text);
      return;
    }
    
    // 使用 Edge TTS（推荐）
    if (_currentSource == 'edge') {
      try {
        await _edgeEngine.speakChinese(text);
        debugPrint("Edge TTS speakChinese: $text");
      } catch (e) {
        debugPrint("Edge TTS speakChinese 错误: $e, 降级到系统 TTS");
        await _speakWithSystemTts(text, "zh-CN");
      }
      return;
    }

    // 使用系统 TTS
    await _speakWithSystemTts(text, "zh-CN");
  }

  /// 停止朗读
  Future<void> stop() async {
    await _systemTts.stop();
    await _edgeEngine.stop();
  }

  /// 循环播放单词进行听写 (报幕式)
  /// 
  /// [english] 如果提供，将朗读英语两次。
  /// [chinese] 如果提供，将朗读中文一次。
  Future<void> speakForDictation({String? english, String? chinese}) async {
    if (english != null && english.isNotEmpty) {
      await speakEnglish(english);
      await Future.delayed(const Duration(milliseconds: 800));
      await speakEnglish(english);
    }
    
    if (chinese != null && chinese.isNotEmpty) {
      // 如果前面读了英语，等待一会儿再读中文
      if (english != null && english.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      await speakChinese(chinese);
    }
  }

  /// 中英混读 (一次性播放)
  /// 
  /// Edge TTS 和讯飞引擎支持中英混读，系统 TTS 则需要分开处理。
  Future<void> speakMixed(String text) async {
    if (_currentSource == 'edge') {
      // Edge TTS 使用多语言语音，可直接混读
      try {
        await _edgeEngine.speak(text);
      } catch (e) {
        debugPrint("Edge TTS speakMixed 错误: $e");
        await _speakWithSystemTts(text, "en-US");
      }
    } else if (_currentSource == 'xfyun') {
      await _xfyunEngine.speak(text);
    } else {
      await _speakWithSystemTts(text, "en-US");
    }
  }
  
  /// 释放资源
  Future<void> dispose() async {
    await _edgeEngine.dispose();
  }
}

