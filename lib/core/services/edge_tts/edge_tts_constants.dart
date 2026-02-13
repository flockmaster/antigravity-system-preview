/// Edge TTS 常量定义
/// 
/// 这些常量从 Python edge-tts 项目移植而来，用于连接微软 Edge TTS 服务。
library edge_tts_constants;

/// 基础 URL
const String edgeTtsBaseUrl = 'speech.platform.bing.com/consumer/speech/synthesize/readaloud';

/// 受信任的客户端令牌
const String edgeTtsTrustedClientToken = '6A5AA1D4EAFF4E9FB37E23D68491D6F4';

/// WebSocket 连接 URL
const String edgeTtsWssUrl = 'wss://$edgeTtsBaseUrl/edge/v1?TrustedClientToken=$edgeTtsTrustedClientToken';

/// 语音列表 URL
const String edgeTtsVoiceListUrl = 'https://$edgeTtsBaseUrl/voices/list?trustedclienttoken=$edgeTtsTrustedClientToken';

/// 默认语音
const String edgeTtsDefaultVoice = 'en-US-EmmaMultilingualNeural';

/// Chromium 版本信息（用于 User-Agent）
const String chromiumFullVersion = '143.0.3650.75';
const String chromiumMajorVersion = '143';
const String secMsGecVersion = '1-$chromiumFullVersion';

/// 基础 HTTP 请求头
const Map<String, String> edgeTtsBaseHeaders = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/$chromiumMajorVersion.0.0.0 Safari/537.36 '
      'Edg/$chromiumMajorVersion.0.0.0',
  'Accept-Encoding': 'gzip, deflate, br, zstd',
  'Accept-Language': 'en-US,en;q=0.9',
};

/// WebSocket 请求头
Map<String, String> get edgeTtsWssHeaders => {
  'Pragma': 'no-cache',
  'Cache-Control': 'no-cache',
  'Origin': 'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold',
  ...edgeTtsBaseHeaders,
};

/// 英语口音类型枚举
enum EnglishAccent {
  /// 美式英语
  american,
  /// 英式英语
  british,
}

/// 语音信息模型
class VoiceInfo {
  /// 语音ID，如 'en-US-EmmaMultilingualNeural'
  final String id;
  /// 显示名称，如 'Emma'
  final String name;
  /// 性别：male/female
  final String gender;
  /// 描述
  final String description;
  /// 口音类型（仅英语语音有效）
  final EnglishAccent? accent;
  /// 语言代码
  final String language;

  const VoiceInfo({
    required this.id,
    required this.name,
    required this.gender,
    required this.description,
    this.accent,
    required this.language,
  });

  /// 是否为女声
  bool get isFemale => gender == 'female';
  
  /// 是否为男声
  bool get isMale => gender == 'male';
}

/// 常用中文语音列表
class EdgeTtsVoices {
  /// 晓晓 - 中文女声（活泼）
  static const String zhCNXiaoxiao = 'zh-CN-XiaoxiaoNeural';
  
  /// 晓伊 - 中文女声（温柔）
  static const String zhCNXiaoyi = 'zh-CN-XiaoyiNeural';
  
  /// 云希 - 中文男声
  static const String zhCNYunxi = 'zh-CN-YunxiNeural';
  
  /// 云扬 - 中文男声（新闻播报）
  static const String zhCNYunyang = 'zh-CN-YunyangNeural';
  
  /// 云健 - 中文男声（运动解说）
  static const String zhCNYunjian = 'zh-CN-YunjianNeural';
  
  /// 晓悠 - 中文女声（儿童故事）
  static const String zhCNXiaoyou = 'zh-CN-XiaoyouNeural';
  
  /// 晓晨 - 中文女声（客服）
  static const String zhCNXiaochen = 'zh-CN-XiaochenNeural';
  
  /// 晓涵 - 中文女声（温暖）
  static const String zhCNXiaohan = 'zh-CN-XiaohanNeural';
  
  /// 晓梦 - 中文女声（甜美）
  static const String zhCNXiaomeng = 'zh-CN-XiaomengNeural';
  
  /// 晓墨 - 中文女声（文艺）
  static const String zhCNXiaomo = 'zh-CN-XiaomoNeural';
  
  /// 晓秋 - 中文女声（知性）
  static const String zhCNXiaoqiu = 'zh-CN-XiaoqiuNeural';
  
  /// 晓睿 - 中文女声（新闻）
  static const String zhCNXiaorui = 'zh-CN-XiaoruiNeural';
  
  /// 晓双 - 中文女声（儿童）
  static const String zhCNXiaoshuang = 'zh-CN-XiaoshuangNeural';
  
  /// 晓萱 - 中文女声（温柔）
  static const String zhCNXiaoxuan = 'zh-CN-XiaoxuanNeural';
  
  /// 晓颜 - 中文女声（专业）
  static const String zhCNXiaoyan = 'zh-CN-XiaoyanNeural';
  
  /// 晓悠 - 中文女声（儿童故事）
  static const String zhCNXiaozhen = 'zh-CN-XiaozhenNeural';
  
  // === 美式英语语音 (en-US) ===
  
  /// Emma - 美式英语女声（多语言）
  static const String enUSEmma = 'en-US-EmmaMultilingualNeural';
  
  /// Jenny - 美式英语女声
  static const String enUSJenny = 'en-US-JennyNeural';
  
  /// Guy - 美式英语男声
  static const String enUSGuy = 'en-US-GuyNeural';
  
  /// Aria - 美式英语女声
  static const String enUSAria = 'en-US-AriaNeural';
  
  /// Davis - 美式英语男声
  static const String enUSDavis = 'en-US-DavisNeural';
  
  // === 英式英语语音 (en-GB) ===
  
  /// Libby - 英式英语女声（友好自然）
  static const String enGBLibby = 'en-GB-LibbyNeural';
  
  /// Sonia - 英式英语女声（优雅专业）
  static const String enGBSonia = 'en-GB-SoniaNeural';
  
  /// Ryan - 英式英语男声（友好专业）
  static const String enGBRyan = 'en-GB-RyanNeural';
  
  /// 获取推荐的中文语音
  static String get defaultChinese => zhCNXiaoxiao;
  
  /// 获取推荐的英文语音（默认美式）
  static String get defaultEnglish => enUSEmma;
  
  /// 根据口音获取默认英语语音
  static String getDefaultEnglishByAccent(EnglishAccent accent) {
    return accent == EnglishAccent.british ? enGBSonia : enUSEmma;
  }
  
  /// 获取美式英语语音列表
  static List<VoiceInfo> get americanVoices => [
    const VoiceInfo(
      id: enUSEmma,
      name: 'Emma',
      gender: 'female',
      description: '多语言女声，自然流畅（推荐）',
      accent: EnglishAccent.american,
      language: 'en-US',
    ),
    const VoiceInfo(
      id: enUSJenny,
      name: 'Jenny',
      gender: 'female',
      description: '女声，亲切友好',
      accent: EnglishAccent.american,
      language: 'en-US',
    ),
    const VoiceInfo(
      id: enUSAria,
      name: 'Aria',
      gender: 'female',
      description: '女声，专业正式',
      accent: EnglishAccent.american,
      language: 'en-US',
    ),
    const VoiceInfo(
      id: enUSGuy,
      name: 'Guy',
      gender: 'male',
      description: '男声，成熟稳重',
      accent: EnglishAccent.american,
      language: 'en-US',
    ),
    const VoiceInfo(
      id: enUSDavis,
      name: 'Davis',
      gender: 'male',
      description: '男声，友好专业',
      accent: EnglishAccent.american,
      language: 'en-US',
    ),
  ];
  
  /// 获取英式英语语音列表
  static List<VoiceInfo> get britishVoices => [
    const VoiceInfo(
      id: enGBSonia,
      name: 'Sonia',
      gender: 'female',
      description: '女声，优雅专业（推荐）',
      accent: EnglishAccent.british,
      language: 'en-GB',
    ),
    const VoiceInfo(
      id: enGBLibby,
      name: 'Libby',
      gender: 'female',
      description: '女声，友好自然',
      accent: EnglishAccent.british,
      language: 'en-GB',
    ),
    const VoiceInfo(
      id: enGBRyan,
      name: 'Ryan',
      gender: 'male',
      description: '男声，友好专业',
      accent: EnglishAccent.british,
      language: 'en-GB',
    ),
  ];
  
  /// 根据口音获取语音列表
  static List<VoiceInfo> getVoicesByAccent(EnglishAccent accent) {
    return accent == EnglishAccent.british ? britishVoices : americanVoices;
  }
  
  /// 获取中文语音列表
  static List<VoiceInfo> get chineseVoices => [
    const VoiceInfo(
      id: zhCNXiaoxiao,
      name: '晓晓',
      gender: 'female',
      description: '活泼女声（推荐）',
      language: 'zh-CN',
    ),
    const VoiceInfo(
      id: zhCNXiaoyi,
      name: '晓伊',
      gender: 'female',
      description: '温柔女声',
      language: 'zh-CN',
    ),
    const VoiceInfo(
      id: zhCNYunxi,
      name: '云希',
      gender: 'male',
      description: '自然男声',
      language: 'zh-CN',
    ),
    const VoiceInfo(
      id: zhCNYunyang,
      name: '云扬',
      gender: 'male',
      description: '新闻播报男声',
      language: 'zh-CN',
    ),
    const VoiceInfo(
      id: zhCNYunjian,
      name: '云健',
      gender: 'male',
      description: '运动解说男声',
      language: 'zh-CN',
    ),
  ];
}

/// 音频输出格式
class EdgeTtsOutputFormat {
  /// MP3 格式 - 24kHz, 48kbps, 单声道
  static const String audio24khz48kbitrateMonoMp3 = 'audio-24khz-48kbitrate-mono-mp3';
  
  /// MP3 格式 - 24kHz, 96kbps, 单声道
  static const String audio24khz96kbitrateMonoMp3 = 'audio-24khz-96kbitrate-mono-mp3';
  
  /// MP3 格式 - 48kHz, 192kbps, 单声道
  static const String audio48khz192kbitrateMonoMp3 = 'audio-48khz-192kbitrate-mono-mp3';
  
  /// 默认格式
  static const String defaultFormat = audio24khz48kbitrateMonoMp3;
}
