import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:uuid/uuid.dart';

import 'edge_tts_constants.dart';
import 'edge_tts_config.dart';
import 'edge_tts_drm.dart';

/// TTS 响应数据块类型
enum EdgeTtsChunkType {
  audio,
  wordBoundary,
  sentenceBoundary,
  sessionEnd,
}

/// TTS 响应数据块
class EdgeTtsChunk {
  final EdgeTtsChunkType type;
  final Uint8List? audioData;
  final int? offset;
  final int? duration;
  final String? text;
  
  EdgeTtsChunk({
    required this.type,
    this.audioData,
    this.offset,
    this.duration,
    this.text,
  });
  
  /// 创建音频数据块
  factory EdgeTtsChunk.audio(Uint8List data) {
    return EdgeTtsChunk(type: EdgeTtsChunkType.audio, audioData: data);
  }
  
  /// 创建词边界数据块
  factory EdgeTtsChunk.wordBoundary({
    required int offset,
    required int duration,
    required String text,
  }) {
    return EdgeTtsChunk(
      type: EdgeTtsChunkType.wordBoundary,
      offset: offset,
      duration: duration,
      text: text,
    );
  }
}

/// Edge TTS 通信类
/// 
/// 通过 WebSocket 与微软 Edge TTS 服务通信，实现文本转语音功能。
/// 从 Python edge-tts 项目移植。
class EdgeTtsCommunicate {
  static const _uuid = Uuid();
  
  final String text;
  final EdgeTtsConfig config;
  
  WebSocketChannel? _channel;
  bool _isConnected = false;
  
  EdgeTtsCommunicate({
    required this.text,
    EdgeTtsConfig? config,
  }) : config = config ?? EdgeTtsConfig();
  
  /// 生成连接 ID（无连字符的 UUID）
  static String _connectId() {
    return _uuid.v4().replaceAll('-', '');
  }
  
  /// 数字补零
  static String _padTwo(int n) => n.toString().padLeft(2, '0');
  
  /// 生成 JavaScript 风格的日期字符串
  static String _dateToString() {
    final now = DateTime.now().toUtc();
    // 格式: "Mon Jan 27 2026 03:31:34 GMT+0000 (Coordinated Universal Time)"
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[now.weekday % 7];
    final month = months[now.month - 1];
    
    return '$weekday $month ${_padTwo(now.day)} ${now.year} '
           '${_padTwo(now.hour)}:${_padTwo(now.minute)}:${_padTwo(now.second)} '
           'GMT+0000 (Coordinated Universal Time)';
  }
  
  /// 对文本进行 XML 转义
  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
  
  /// 移除不兼容的字符
  static String _removeIncompatibleCharacters(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if ((code >= 0 && code <= 8) || (code >= 11 && code <= 12) || (code >= 14 && code <= 31)) {
        buffer.write(' ');
      } else {
        buffer.write(text[i]);
      }
    }
    return buffer.toString();
  }
  
  /// 生成 SSML 字符串
  String _makeSSML(String escapedText) {
    return "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='en-US'>"
           "<voice name='${config.voice}'>"
           "<prosody pitch='${config.pitch}' rate='${config.rate}' volume='${config.volume}'>"
           "$escapedText"
           "</prosody>"
           "</voice>"
           "</speak>";
  }
  
  /// 生成 SSML 请求头和数据
  String _ssmlHeadersPlusData(String requestId, String timestamp, String ssml) {
    return 'X-RequestId:$requestId\r\n'
           'Content-Type:application/ssml+xml\r\n'
           'X-Timestamp:${timestamp}Z\r\n'
           'Path:ssml\r\n\r\n'
           '$ssml';
  }
  
  /// 获取 WebSocket URL
  String _getWebSocketUrl() {
    final connectionId = _connectId();
    final secMsGec = EdgeTtsDrm.generateSecMsGec();
    return '$edgeTtsWssUrl&ConnectionId=$connectionId'
           '&Sec-MS-GEC=$secMsGec'
           '&Sec-MS-GEC-Version=$secMsGecVersion';
  }
  
  /// 解析二进制消息头
  static Map<String, String> _parseHeaders(Uint8List data, int headerLength) {
    final headers = <String, String>{};
    final headerBytes = data.sublist(0, headerLength);
    final headerStr = utf8.decode(headerBytes);
    
    for (final line in headerStr.split('\r\n')) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex);
        final value = line.substring(colonIndex + 1);
        headers[key] = value;
      }
    }
    
    return headers;
  }
  
  /// 解析文本消息的头和数据
  static (Map<String, String>, String) _getHeadersAndDataFromText(String message) {
    final separatorIndex = message.indexOf('\r\n\r\n');
    if (separatorIndex < 0) {
      return (<String, String>{}, message);
    }
    
    final headers = <String, String>{};
    final headerPart = message.substring(0, separatorIndex);
    for (final line in headerPart.split('\r\n')) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex);
        final value = line.substring(colonIndex + 1);
        headers[key] = value;
      }
    }
    
    final data = message.substring(separatorIndex + 4);
    return (headers, data);
  }
  
  /// 流式获取 TTS 数据
  /// 
  /// 返回一个 Stream，包含音频数据和元数据。
  Stream<EdgeTtsChunk> stream() async* {
    // 准备文本
    final cleanedText = _removeIncompatibleCharacters(text);
    final escapedText = _escapeXml(cleanedText);
    
    // 构建 WebSocket URL
    final wsUrl = _getWebSocketUrl();
    debugPrint('Edge TTS: 连接到 $wsUrl');
    
    // 连接 WebSocket
    try {
      // 构建带头部的 WebSocket 连接
      // 完全对齐 Python edge-tts 库的头部格式
      // 参考: https://github.com/rany2/edge-tts
      
      // 生成随机 MUID（关键！Python 版本也使用这个）
      final muid = EdgeTtsDrm.generateMuid();
      
      // 完全复制 Python 的请求头顺序和格式
      final headers = {
        // WSS_HEADERS (来自 Python constants.py)
        'Pragma': 'no-cache',
        'Cache-Control': 'no-cache',
        'Origin': 'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold',
        'Sec-WebSocket-Version': '13',  // 关键！之前缺失
        // BASE_HEADERS (来自 Python constants.py)
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/$chromiumMajorVersion.0.0.0 Safari/537.36 '
            'Edg/$chromiumMajorVersion.0.0.0',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Accept-Language': 'en-US,en;q=0.9',
        // MUID Cookie (来自 Python DRM.headers_with_muid)
        'Cookie': 'muid=$muid;',
      };
      debugPrint('Edge TTS: 连接 URL: $wsUrl');
      
      // 使用 HttpClient 并配置 User-Agent
      // 必须在这里设置 UA，否则 Dart 默认会使用 Dart/<version>，导致被拦截
      final client = HttpClient()
        ..userAgent = headers['User-Agent']; // 提取并设置正确的 UA
        
      // 移除可能导致冲突的头部
      headers.remove('User-Agent'); // 已通过 client.userAgent 设置
      headers.remove('Sec-WebSocket-Version'); // 由系统自动管理
      headers.remove('Connection'); // 系统管理
      headers.remove('Upgrade'); // 系统管理
      
      // 使用 dart:io 的 WebSocket.connect 并传入 customClient
      final ws = await WebSocket.connect(
        wsUrl, 
        headers: headers,
        customClient: client, // 关键！使用自定义 client
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Edge TTS WebSocket 连接超时 (15s)');
        },
      );
      _channel = IOWebSocketChannel(ws);
      
      _isConnected = true;
      debugPrint('Edge TTS: WebSocket 连接成功');
      
      // 发送配置请求
      final configMessage = 'X-Timestamp:${_dateToString()}\r\n'
          'Content-Type:application/json; charset=utf-8\r\n'
          'Path:speech.config\r\n\r\n'
          '{"context":{"synthesis":{"audio":{"metadataoptions":{'
          '"sentenceBoundaryEnabled":"true","wordBoundaryEnabled":"true"'
          '},'
          '"outputFormat":"${config.outputFormat}"'
          '}}}}';
      
      _channel!.sink.add(configMessage);
      debugPrint('Edge TTS: 已发送配置');
      
      // 发送 SSML 请求
      final ssml = _makeSSML(escapedText);
      final ssmlMessage = _ssmlHeadersPlusData(_connectId(), _dateToString(), ssml);
      _channel!.sink.add(ssmlMessage);
      debugPrint('Edge TTS: 已发送 SSML (文本长度: ${text.length})');
      
      // 监听响应
      bool audioReceived = false;
      
      await for (final message in _channel!.stream) {
        if (message is String) {
          // 文本消息
          final (headers, data) = _getHeadersAndDataFromText(message);
          final path = headers['Path'];
          
          if (path == 'audio.metadata') {
            // 解析元数据
            try {
              final metadata = json.decode(data);
              final metadataList = metadata['Metadata'] as List;
              for (final meta in metadataList) {
                final metaType = meta['Type'] as String;
                if (metaType == 'WordBoundary' || metaType == 'SentenceBoundary') {
                  yield EdgeTtsChunk(
                    type: metaType == 'WordBoundary' 
                        ? EdgeTtsChunkType.wordBoundary 
                        : EdgeTtsChunkType.sentenceBoundary,
                    offset: meta['Data']['Offset'] as int,
                    duration: meta['Data']['Duration'] as int,
                    text: meta['Data']['text']['Text'] as String,
                  );
                }
              }
            } catch (e) {
              debugPrint('Edge TTS: 解析元数据失败: $e');
            }
          } else if (path == 'turn.end') {
            // 结束信号
            debugPrint('Edge TTS: 收到结束信号');
            break;
          }
        } else if (message is List<int>) {
          // 二进制消息（音频数据）
          final data = Uint8List.fromList(message);
          
          if (data.length < 2) {
            debugPrint('Edge TTS: 二进制消息太短');
            continue;
          }
          
          // 前两字节是头部长度
          final headerLength = (data[0] << 8) | data[1];
          if (headerLength + 2 > data.length) {
            debugPrint('Edge TTS: 头部长度无效');
            continue;
          }
          
          // 解析头部
          final headers = _parseHeaders(data.sublist(2), headerLength);
          final path = headers['Path'];
          
          if (path == 'audio') {
            // 提取音频数据
            final audioData = data.sublist(2 + headerLength);
            if (audioData.isNotEmpty) {
              audioReceived = true;
              yield EdgeTtsChunk.audio(audioData);
            }
          }
        }
      }
      
      if (!audioReceived) {
        throw Exception('Edge TTS: 未收到音频数据');
      }
      
    } catch (e) {
      debugPrint('Edge TTS 错误: $e');
      rethrow;
    } finally {
      await close();
    }
  }
  
  /// 获取完整的音频数据
  /// 
  /// 将所有音频块合并为一个完整的 MP3 数据。
  Future<Uint8List> getAudio() async {
    final chunks = <Uint8List>[];
    
    await for (final chunk in stream()) {
      if (chunk.type == EdgeTtsChunkType.audio && chunk.audioData != null) {
        chunks.add(chunk.audioData!);
      }
    }
    
    // 合并所有音频块
    int totalLength = 0;
    for (final chunk in chunks) {
      totalLength += chunk.length;
    }
    
    final result = Uint8List(totalLength);
    int offset = 0;
    for (final chunk in chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    
    debugPrint('Edge TTS: 音频合成完成，总大小: ${result.length} 字节');
    return result;
  }
  
  /// 关闭连接
  Future<void> close() async {
    if (_isConnected && _channel != null) {
      await _channel!.sink.close();
      _isConnected = false;
      debugPrint('Edge TTS: 连接已关闭');
    }
  }
}
