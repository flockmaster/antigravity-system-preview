/// Application Configuration
/// 
/// Contains compilation-time constants and runtime settings.
class AppConfig {
  /// --- AI 模型选择 ---
  /// 选择当前使用的 AI 类型: 'gemini' 或 'doubao'
  static const String activeAiType = 'doubao'; 

  /// --- Gemini 配置 ---
  /// Gemini API Key
  static const String geminiApiKey = 'AIzaSyBDT1X20BHGJeMHqI-LcdGpV3pzhZN2mRE';
  /// Gemini Model Name
  static const String geminiModelName = 'gemini-3-flash-preview';

  /// --- 豆包 (Doubao/Ark) 配置 ---
  /// 豆包 API Key
  static const String doubaoApiKey = '4d3b6638-b7d5-4d81-8150-e52dfba7547c';
  /// 豆包 API Base URL
  static const String doubaoBaseUrl = 'https://ark.cn-beijing.volces.com/api/v3';
  /// 豆包 Model Endpoint ID (实例代码中的 model)
  static const String doubaoModelEndpoint = 'doubao-seed-1-6-251015';

  /// --- 科大讯飞 (iFlytek) 配置 ---
  /// APPID
  static const String xfyunAppId = 'b3510218';
  /// APISecret
  static const String xfyunApiSecret = 'Y2M0OWUxN2IxNjM5NWIyMjg0MmE1MTYy';
  /// APIKey
  static const String xfyunApiKey = '72a8db05c580e29055b3a70cd9cd6ee1';
  /// 超拟人 TTS 地址
  static const String xfyunTtsUrl = 'wss://cbm01.cn-huabei-1.xf-yun.com/v1/private/mcd9m97e6';


  /// 是否使用真实 AI 服务
  static const bool useGenerativeAi = true;

  /// Private constructor to prevent instantiation
  AppConfig._();
}
