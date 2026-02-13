import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import 'edge_tts_constants.dart';

/// Edge TTS DRM 处理类
/// 
/// 处理微软 Edge TTS 服务的 DRM 认证，包括时钟偏移校正和 Sec-MS-GEC 令牌生成。
/// 从 Python edge-tts 项目的 drm.py 移植。
class EdgeTtsDrm {
  /// Windows 纪元偏移（1601年1月1日到1970年1月1日的秒数）
  static const int winEpoch = 11644473600;
  
  /// 秒转纳秒的倍数
  static const double sToNs = 1e9;
  
  /// 时钟偏移（秒）
  static double clockSkewSeconds = 0.0;
  
  /// 调整时钟偏移
  static void adjustClockSkewSeconds(double skewSeconds) {
    clockSkewSeconds += skewSeconds;
  }
  
  /// 获取带时钟偏移校正的 Unix 时间戳
  static double getUnixTimestamp() {
    return DateTime.now().toUtc().millisecondsSinceEpoch / 1000.0 + clockSkewSeconds;
  }
  
  /// 解析 RFC 2616 日期字符串
  /// 
  /// 返回 Unix 时间戳，解析失败返回 null。
  static double? parseRfc2616Date(String date) {
    try {
      // 例如: "Mon, 27 Jan 2026 03:31:34 GMT"
      final dateTime = _parseHttpDate(date);
      return dateTime?.millisecondsSinceEpoch.toDouble();
    } catch (e) {
      return null;
    }
  }
  
  /// 解析 HTTP 日期格式
  static DateTime? _parseHttpDate(String date) {
    // HTTP 日期格式: "Mon, 27 Jan 2026 03:31:34 GMT"
    final months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    
    try {
      final parts = date.split(' ');
      if (parts.length < 5) return null;
      
      final day = int.parse(parts[1]);
      final month = months[parts[2]];
      final year = int.parse(parts[3]);
      final timeParts = parts[4].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final second = int.parse(timeParts[2]);
      
      if (month == null) return null;
      
      return DateTime.utc(year, month, day, hour, minute, second);
    } catch (e) {
      return null;
    }
  }
  
  /// 处理服务器响应错误（用于时钟偏移校正）
  static void handleServerDateHeader(Map<String, String> headers) {
    final serverDate = headers['Date'] ?? headers['date'];
    if (serverDate == null) return;
    
    final serverDateParsed = parseRfc2616Date(serverDate);
    if (serverDateParsed == null) return;
    
    final clientDate = getUnixTimestamp();
    adjustClockSkewSeconds(serverDateParsed - clientDate);
  }
  
  /// 生成 Sec-MS-GEC 令牌
  /// 
  /// 基于当前时间（Windows 文件时间格式，向下取整到最近的5分钟），
  /// 使用 SHA256 哈希生成令牌。
  static String generateSecMsGec() {
    // 获取带时钟偏移校正的 Unix 时间戳
    double ticks = getUnixTimestamp();
    
    // 转换到 Windows 文件时间纪元（1601-01-01 00:00:00 UTC）
    ticks += winEpoch;
    
    // 向下取整到最近的5分钟（300秒）
    ticks -= ticks % 300;
    
    // 转换为100纳秒间隔（Windows 文件时间格式）
    ticks *= sToNs / 100;
    
    // 创建待哈希的字符串：时间戳 + 受信任客户端令牌
    final strToHash = '${ticks.toInt()}$edgeTtsTrustedClientToken';
    
    // 计算 SHA256 哈希
    final bytes = utf8.encode(strToHash);
    final digest = sha256.convert(bytes);
    
    // 关键修复：digest.toString() 可能丢失前导零！
    // 必须确保输出始终是 64 位十六进制字符串
    // 使用 padLeft(64, '0') 填充前导零
    return digest.toString().toUpperCase().padLeft(64, '0');
  }
  
  /// 生成随机 MUID
  static String generateMuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }
  
  /// 获取带 MUID 的请求头
  static Map<String, String> headersWithMuid(Map<String, String> headers) {
    final combinedHeaders = Map<String, String>.from(headers);
    combinedHeaders['Cookie'] = 'muid=${generateMuid()};';
    return combinedHeaders;
  }
}
