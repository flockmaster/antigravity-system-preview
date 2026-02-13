import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// 科大讯飞超拟人 TTS 引擎
class XfyunTtsEngine {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // 缓存目录
  Directory? _cacheDir;
  
  /// 获取缓存目录
  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/xfyun_tts_cache');
    
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    
    return _cacheDir!;
  }
  
  /// 根据文本生成缓存文件名 (MD5 hash)
  String _getCacheFileName(String text, String vcn) {
    final content = '$vcn:$text';
    final hash = md5.convert(utf8.encode(content)).toString();
    return '$hash.mp3';
  }
  
  /// 检查缓存是否存在
  Future<File?> _checkCache(String text, String vcn) async {
    final cacheDir = await _getCacheDir();
    final fileName = _getCacheFileName(text, vcn);
    final cacheFile = File('${cacheDir.path}/$fileName');
    
    if (await cacheFile.exists()) {
      debugPrint('讯飞 TTS: 缓存命中 "$text"');
      return cacheFile;
    }
    return null;
  }
  
  /// 保存到缓存
  Future<File> _saveToCache(String text, String vcn, List<int> audioData) async {
    final cacheDir = await _getCacheDir();
    final fileName = _getCacheFileName(text, vcn);
    final cacheFile = File('${cacheDir.path}/$fileName');
    
    await cacheFile.writeAsBytes(audioData);
    debugPrint('讯飞 TTS: 已缓存 "$text" 的音频 (${audioData.length} 字节)');
    
    return cacheFile;
  }
  
  /// 获取鉴权地址
  String _getAuthUrl() {
    final uri = Uri.parse(AppConfig.xfyunTtsUrl);
    final date = '${DateFormat('EEE, dd MMM yyyy HH:mm:ss').format(DateTime.now().toUtc())} GMT';
    
    // 签名串: host, date, request-line
    final signatureOrigin = "host: ${uri.host}\ndate: $date\nGET ${uri.path} HTTP/1.1";
    
    // HMAC-SHA256 加密
    final hmacSha256 = Hmac(sha256, utf8.encode(AppConfig.xfyunApiSecret));
    final signature = base64.encode(hmacSha256.convert(utf8.encode(signatureOrigin)).bytes);
    
    // 构建 authorization 参数
    final authOrigin = 'api_key="${AppConfig.xfyunApiKey}", algorithm="hmac-sha256", headers="host date request-line", signature="$signature"';
    final authorization = base64.encode(utf8.encode(authOrigin));
    
    // 最终 URL
    final queryParams = {
      'host': uri.host,
      'date': date,
      'authorization': authorization,
    };
    
    return uri.replace(queryParameters: queryParams).toString();
  }



  /// 播放语音 (阻塞式，等待播放完成，支持缓存)
  Future<void> speak(String text, {String vcn = 'x6_lingxiaoxuan_pro'}) async {
    final completer = Completer<void>();
    
    try {
      // 1. 先检查缓存
      final cachedFile = await _checkCache(text, vcn);
      if (cachedFile != null) {
        // 缓存命中，直接播放
        await _playAudioFile(cachedFile, completer);
        return completer.future;
      }
      
      // 2. 缓存未命中，调用 API
      debugPrint('讯飞 TTS: 缓存未命中，正在为 "$text" 请求接口');
      final authUrl = _getAuthUrl();
      
      final channel = IOWebSocketChannel.connect(authUrl);
      
      // 保存音频数据
      final List<int> audioData = [];


      // 发送请求消息 (按照官方文档格式)
      final request = {
        "header": {
          "app_id": AppConfig.xfyunAppId,
          "status": 2  // 2 表示一次性发送完毕
        },
        "parameter": {
          "tts": {
            "vcn": vcn,
            "speed": 50,
            "volume": 50,
            "pitch": 50,
            "bgs": 0,
            "reg": 0,
            "rdn": 0,
            "rhy": 0,
            "audio": {
              "encoding": "lame",  // lame = mp3 格式
              "sample_rate": 24000,
              "channels": 1,
              "bit_depth": 16,
              "frame_size": 0
            }
          }
        },
        "payload": {
          "text": {
            "encoding": "utf8",
            "compress": "raw",
            "format": "plain",
            "status": 2,
            "seq": 0,
            "text": base64.encode(utf8.encode(text))  // 文本需要 base64 编码
          }
        }
      };

      channel.sink.add(json.encode(request));

      // 监听响应
      channel.stream.listen((message) async {
        final Map<String, dynamic> response = json.decode(message);
        final header = response['header'];
        
        if (header['code'] != 0) {
          String errorMsg = '${header['code']} - ${header['message']}';
          if (header['code'] == 11200) {
            errorMsg += ' (授权失败：请检查讯飞控制台是否已开通"超拟人语音合成"服务，或服务额度是否已用完)';
          }
          debugPrint('讯飞 TTS 错误: $errorMsg');
          channel.sink.close();
          if (!completer.isCompleted) completer.complete();
          return;
        }

        final payload = response['payload'];
        if (payload != null && payload['audio'] != null && payload['audio']['audio'] != null) {
          final String audioBase64 = payload['audio']['audio'];
          audioData.addAll(base64.decode(audioBase64));
          
          if (header['status'] == 2) {
            channel.sink.close();
            
            if (audioData.isNotEmpty) {
              // 3. 保存到缓存
              final cacheFile = await _saveToCache(text, vcn, audioData);
              
              // 4. 播放音频
              await _playAudioFile(cacheFile, completer);
            } else {
              if (!completer.isCompleted) completer.complete();
            }
          }
        }
      }, onError: (error) {
        debugPrint('讯飞 TTS WebSocket 错误: $error');
        if (!completer.isCompleted) completer.complete();
      }, onDone: () {
        debugPrint('讯飞 TTS WebSocket 完成');
        // 不在这里 complete，因为 WebSocket 关闭不代表播放完成
      });

    } catch (e) {
      debugPrint('Xfyun TTS Exception: $e');
      if (!completer.isCompleted) completer.complete();
    }
    
    // 等待播放完成
    return completer.future;
  }
  
  /// 播放音频文件并等待完成
  Future<void> _playAudioFile(File audioFile, Completer<void> completer) async {
    try {
      // 设置播放完成回调
      _audioPlayer.onPlayerComplete.listen((_) {
        if (!completer.isCompleted) completer.complete();
      });
      
      // 设置播放模式
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);
      // 设置音频源并播放
      await _audioPlayer.setSource(DeviceFileSource(audioFile.path));
      await _audioPlayer.resume();
      // 注意: 这里不直接 complete，而是等待 onPlayerComplete 回调
    } catch (e) {
      debugPrint('讯飞 TTS 播放错误: $e');
      if (!completer.isCompleted) completer.complete();
    }
  }




  Future<void> stop() async {
    await _audioPlayer.stop();
  }
}
