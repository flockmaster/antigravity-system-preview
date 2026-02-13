
import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import '../../app/app.locator.dart';
import '../config/app_config.dart';
import '../models/word.dart';
import '../models/dictation_session.dart';
import '../utils/app_logger.dart';

/// AI 核心服务类
/// 
/// 负责与 Google Gemini API 或 豆包 (Doubao) API 进行交互。
class AiService with ListenableServiceMixin {
  GenerativeModel? _geminiModel;
  final _dialogService = locator<DialogService>();
  final _dio = Dio();
  
  /// 提取模式到指令的映射
  static const Map<String, String> _modeInstructions = {
    'smart': '用户在视觉上标记的英文单词（如 打钩 √, 圈画 O, 下划线, 括号或荧光笔标记）。',
    'circle': '被手写圆圈圈出的英文单词。',
    'check': '被标记了打钩符号 (√) 的英文单词。',
    'all': '页面上所有清晰可见的英文字汇。',
  };

  AiService() {
    _initializeModels();
  }

  /// 初始化 AI 模型
  void _initializeModels() {
    // 1. 初始化 Gemini (如果配置存在)
    if (AppConfig.geminiApiKey.isNotEmpty && AppConfig.geminiApiKey != 'YOUR_API_KEY_HERE') {
      final responseSchema = Schema.array(
        items: Schema.object(
          properties: {
            'word': Schema.string(description: '英文单词'),
            'phonetic': Schema.string(description: '美式音标 (IPA)'),
            'meaning_full': Schema.string(description: '完整中文释义'),
            'meaning_for_dictation': Schema.string(description: '用于听写报幕的简短中文释义'),
            'sentence': Schema.string(description: '简单的例句'),
            'mnemonic': Schema.string(description: '记忆法 (联想记忆/谐音等), 例如: pest -> 拍死它 -> 害虫'),
          },
          requiredProperties: ['word', 'meaning_for_dictation', 'mnemonic'],
        ),
      );

      _geminiModel = GenerativeModel(
        model: AppConfig.geminiModelName, 
        apiKey: AppConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: responseSchema,
        ),
      );
    }
  }
  
  /// 检查 AI 服务是否已准备就绪
  bool get isReady {
    if (AppConfig.activeAiType == 'doubao') {
      return AppConfig.doubaoApiKey.isNotEmpty;
    }
    return _geminiModel != null;
  }

  /// 从课本图片中提取单词
  Future<List<Word>> extractWordsFromImage(File imageFile, {String mode = 'smart'}) async {
    if (!AppConfig.useGenerativeAi) {
      await Future.delayed(const Duration(seconds: 1));
      return _getMockWords();
    }

    if (AppConfig.activeAiType == 'doubao') {
      return _extractWordsWithDoubao(imageFile, mode);
    } else {
      return _extractWordsWithGemini(imageFile, mode);
    }
  }

  /// 使用 Gemini 提取
  Future<List<Word>> _extractWordsWithGemini(File imageFile, String mode) async {
    if (_geminiModel == null) return [];
    try {
      final imageBytes = await imageFile.readAsBytes();
      final targetCondition = _modeInstructions[mode] ?? _modeInstructions['smart'];

      final prompt = [
        Content.multi([
          TextPart(
            "分析这张课本页面。返回 JSON 数组格式。"
            "提取条件：$targetCondition "
            "JSON包含字段: word, phonetic, meaning_full, meaning_for_dictation, sentence, mnemonic (记忆法)。"
          ),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _geminiModel!.generateContent(prompt);
      return _processJsonResponse(response.text);
    } catch (e) {
      AppLogger.e('Gemini Error', error: e);
      return [];
    }
  }

  /// 使用豆包 (Doubao) 提取
  Future<List<Word>> _extractWordsWithDoubao(File imageFile, String mode) async {
    try {
      // 1. 读取并压缩图片 (防止图片过大导致 API 报错)
      final imageBytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) throw Exception("图片解码失败");

      // 缩放图片，控制在 1024 像素以内
      final resizedImage = img.copyResize(decodedImage, width: 1024);
      final compressedBytes = img.encodeJpg(resizedImage, quality: 80);
      final base64Image = base64Encode(compressedBytes);
      
      final targetCondition = _modeInstructions[mode] ?? _modeInstructions['smart'];
      final optimizedPrompt = 
          "你是一个单词提取引擎。识别图中满足条件的单词：$targetCondition\n\n"
          "必须严格按照以下 JSON 数组格式返回。每个对象必须包含所有 5 个字段（不得缺失）：\n"
          "[\n"
          "  {\n"
          "    \"word\": \"单词原文\",\n"
          "    \"phonetic\": \"/音标/\",\n"
          "    \"meaning_full\": \"完整中文义\",\n"
          "    \"meaning_for_dictation\": \"极简中文义\",\n"
          "    \"sentence\": \"简单的英文例句\",\n"
          "    \"mnemonic\": \"记忆法 (联想/谐音)\"\n"
          "  }\n"
          "]\n\n"
          "输出准则：\n"
          "1. 字段完整性：word, phonetic, meaning_full, meaning_for_dictation, sentence, mnemonic 必须全部返回。\n"
          "2. 记忆法 (Mnemonic)：必须为每个单词匹配最合适的速记方式（如：词根词缀法、谐音梗、联想故事、对比记忆等）。目标是简短、有趣且易于在中文语境下记忆。\n"
          "3. 例句要求：为每个单词生成一个适合小学生难度的、不超过 10 个词的简单英文例句。\n"
          "4. 音标要求：必须包含标准美式 IPA 音标。\n"
          "5. 格式要求：纯 JSON 数组，严禁包含 Markdown 标签或任何其它非 JSON 文字。";

      final response = await _dio.post(
        '${AppConfig.doubaoBaseUrl}/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer ${AppConfig.doubaoApiKey}',
          'Content-Type': 'application/json',
        }),
        data: {
          "model": AppConfig.doubaoModelEndpoint,
          "reasoning_effort": "minimal", // 关键：禁用深度思考，追求极速响应
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": optimizedPrompt},
                {
                  "type": "image_url",
                  "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
                }
              ]
            }
          ],
          "stream": false
        },
      ).timeout(const Duration(seconds: 45));

      debugPrint("Doubao Response: ${jsonEncode(response.data)}");

      final content = response.data['choices']?[0]?['message']?['content'] as String?;
      return _processJsonResponse(content);
    } catch (e) {
      String errorMsg = "识别失败：$e";
      if (e is DioException) {
        final responseData = e.response?.data;
        errorMsg = "网络请求失败 (${e.response?.statusCode}): ${responseData != null ? jsonEncode(responseData) : e.message}";
      }
      
      // 在 UI 上弹出详细错误，方便诊断
      _dialogService.showDialog(
        title: 'AI 识别诊断器',
        description: errorMsg,
        buttonTitle: '了解',
      );
      
      AppLogger.e('Doubao Error: $errorMsg');
      return [];
    }
  }

  /// 从普通文本中提取单词 (适配多模型)
  Future<List<Word>> extractWordsFromText(String text) async {
    if (!AppConfig.useGenerativeAi) return _getMockWords();

    if (AppConfig.activeAiType == 'doubao') {
      try {
        final optimizedPrompt = 
            "你是一个单词提取引擎。分析以下文本并识别所有英文单词。\n\n"
            "必须严格按照以下 JSON 数组格式返回。每个对象不可缺失字段：\n"
            "[\n"
            "  {\n"
            "    \"word\": \"单词原文\",\n"
            "    \"phonetic\": \"/音标/\",\n"
            "    \"meaning_full\": \"完整中文义\",\n"
            "    \"meaning_for_dictation\": \"极简中文义\",\n"
            "    \"sentence\": \"简单的英文例句\",\n"
            "    \"mnemonic\": \"最合适的记忆法 (词根/联想/谐音)\"\n"
            "  }\n"
            "]\n\n"
            "高级要求：\n"
            "1. 记忆法 (Mnemonic)：灵活使用词根词缀、谐音、联想故事或对比记忆。选择最有助于记忆的方式，保持简短有趣。\n"
            "2. 文本内容：$text";

        final response = await _dio.post(
          '${AppConfig.doubaoBaseUrl}/chat/completions',
          options: Options(headers: {
            'Authorization': 'Bearer ${AppConfig.doubaoApiKey}',
            'Content-Type': 'application/json',
          }),
          data: {
            "model": AppConfig.doubaoModelEndpoint,
            "reasoning_effort": "minimal",
            "messages": [
              {
                "role": "user",
                "content": optimizedPrompt
              }
            ],
            "stream": false
          },
        );
        final content = response.data['choices']?[0]?['message']?['content'] as String?;
        return _processJsonResponse(content);
      } catch (e) {
        debugPrint("Doubao extractWordsFromText Error: $e");
        return [];
      }
    } else {
      if (_geminiModel == null) return [];
      final prompt = [Content.multi([
        TextPart(
          "从以下文本提取单词并返回 JSON: $text\n"
          "要求生成字段: word, phonetic, meaning_full, meaning_for_dictation, sentence, mnemonic。\n"
          "【mnemonic (记忆法) 特别指令】：请根据单词特点，灵活选择最合适的记忆方式（如词根词缀、谐音、联想故事、拆分记忆等），用中文简要描述。"
        )
      ])];
      final response = await _geminiModel!.generateContent(prompt);
      return _processJsonResponse(response.text);
    }
  }

  /// 统一处理 JSON 响应
  List<Word> _processJsonResponse(String? text) {
    if (text == null || text.isEmpty) return [];
    try {
      final cleanJson = _cleanJsonString(text);
      final decoded = jsonDecode(cleanJson);
      
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded.containsKey('words')) {
        list = decoded['words'];
      } else if (decoded is Map) {
        // 有时模型会返回 {"results": [...]}
        list = decoded.values.firstWhere((v) => v is List, orElse: () => []);
      } else {
        return [];
      }

      return list.map((item) {
        final data = item as Map<String, dynamic>;
        return Word(
          id: '${DateTime.now().microsecondsSinceEpoch}_${data['word'] ?? 'unknown'}',
          word: data['word'] ?? '',
          phonetic: data['phonetic'] ?? '',
          meaningFull: data['meaning_full'] ?? '',
          meaningForDictation: data['meaning_for_dictation'] ?? '',
          sentence: data['sentence'] ?? '',
          mnemonic: data['mnemonic'] ?? '',
        );
      }).toList();
    } catch (e) {
      AppLogger.e('JSON Decode Error', error: e);
      return [];
    }
  }

  /// 智能批改中文释义 (Mode C)
  /// 
  /// 批量检查用户的中文输入是否符合英文单词的含义
  Future<Map<String, bool>> gradeMeaningDictation(List<Map<String, dynamic>> items) async {
    if (!isReady || items.isEmpty) return {};

    if (AppConfig.activeAiType == 'doubao') {
      try {
        final prompt = StringBuffer();
        prompt.writeln("角色：能够理解语义的智能英语老师。");
        prompt.writeln("任务：批改'英译中'听写。");
        prompt.writeln("请判断学生的【中文回答】是否正确体现了【英文单词】的含义。");
        prompt.writeln("【判分标准】：");
        prompt.writeln("1. 语义正确即得分：回答只要能对应上单词的某一个释义（包括近义词、通俗表达），判为正确。");
        prompt.writeln("2. 容错机制：忽略错别字、同音字（如'环境'写成'环镜'），只要不影响对单词认知的判断，判为正确。");
        prompt.writeln("3. 词性包容：忽略词性差异（名为动、形为名等算对）。");
        prompt.writeln("4. 严格把关：如果回答完全错误、意思相反或毫无关联，必须判错。不要盲目放水。");
        prompt.writeln("\n待批改列表：");
        for (var item in items) {
          prompt.writeln("- ID: ${item['id']}, 英文: ${item['word']} (${item['standard']}), 学生回答: ${item['user_input']}");
        }
        prompt.writeln("\n请返回纯 JSON 对象，键为 ID，值为布尔值（is_correct）。格式必须为：{\"id1\": true, \"id2\": false}");

        final response = await _dio.post(
          '${AppConfig.doubaoBaseUrl}/chat/completions',
          options: Options(headers: {
            'Authorization': 'Bearer ${AppConfig.doubaoApiKey}',
            'Content-Type': 'application/json',
          }),
          data: {
            "model": AppConfig.doubaoModelEndpoint,
            "reasoning_effort": "minimal",
            "messages": [
              {
                "role": "user",
                "content": prompt.toString()
              }
            ],
            "stream": false
          },
        );

        final textContent = response.data['choices']?[0]?['message']?['content'] as String?;
        if (textContent == null) return {};
        
        final Map<String, dynamic> data = jsonDecode(_cleanJsonString(textContent));
        return data.map((key, value) => MapEntry(key, value is bool ? value : false));
      } catch (e) {
        debugPrint("Doubao Grade Error: $e");
        return {};
      }
    } else {
      // Gemini 逻辑
      if (_geminiModel == null) return {};
      // 简单实现：使用内容生成
      try {
         final prompt = "检查这些单词意思是否正确，返回 JSON {id: bool}: $items";
         final response = await _geminiModel!.generateContent([Content.text(prompt)]);
         final Map<String, dynamic> data = jsonDecode(_cleanJsonString(response.text ?? '{}'));
         return data.map((key, value) => MapEntry(key, value as bool));
      } catch (e) {
         return {};
      }
    }
  }

  String _cleanJsonString(String text) {
    text = text.trim();
    if (text.startsWith('```json')) {
      text = text.substring(7, text.length - 3);
    } else if (text.startsWith('```')) {
      text = text.substring(3, text.length - 3);
    }
    return text.trim();
  }

  /// 批改功能后续可按需扩展豆包逻辑，此处先保留原逻辑...
  Future<List<Mistake>> gradeDictation(File imageFile, List<Word> expectedWords) async {
    // 暂时保持 Gemini 逻辑或 Mock
    return _getMockMistakes(expectedWords);
  }

  /// 为单个单词生成记忆法
  Future<String> generateMnemonic(String word, String meaning) async {
    if (!isReady) return '';
    
    final promptText = "为英语单词 '$word' (释义: $meaning) 生成一个简短、有趣、易记的中文记忆法 (速记)。\n"
        "方法可使用：词根词缀、谐音梗、联想故事或拆分记忆。\n"
        "只返回记忆法文本，不要包含'记忆法：'等前缀。";

    try {
      if (AppConfig.activeAiType == 'doubao') {
        final response = await _dio.post(
          '${AppConfig.doubaoBaseUrl}/chat/completions',
          options: Options(headers: {
            'Authorization': 'Bearer ${AppConfig.doubaoApiKey}',
            'Content-Type': 'application/json',
          }),
          data: {
            "model": AppConfig.doubaoModelEndpoint,
            "messages": [
              {"role": "user", "content": promptText}
            ],
            "stream": false
          },
        );
        final content = response.data['choices']?[0]?['message']?['content'] as String?;
        return content?.trim() ?? '';
      } else {
        final response = await _geminiModel!.generateContent([Content.text(promptText)]);
        return response.text?.trim() ?? '';
      }
    } catch (e) {
      debugPrint("Generate Mnemonic Error: $e");
      return '';
    }
  }

  // --- Mock 数据 ---
  List<Word> _getMockWords() {
    return [
      const Word(
        id: 'm1', 
        word: 'curious', 
        phonetic: '/ˈkjʊəriəs/',
        meaningFull: 'adj. 好奇的',
        meaningForDictation: '好奇的',
        sentence: 'I am curious.',
        mnemonic: 'Curious -> 客人(Cur)有事(ious) -> 好奇的',
      ),
      const Word(
        id: 'm2', 
        word: 'environment', 
        phonetic: '/ɪnˈvaɪrənmənt/',
        meaningFull: 'n. 环境',
        meaningForDictation: '环境',
        sentence: 'Protect the environment.',
        mnemonic: 'Environment -> 银(En)味(vi)肉(ron)馒头(ment) -> 环境需保护',
      ),
    ];
  }

  List<Mistake> _getMockMistakes(List<Word> expectedWords) => [];
}


