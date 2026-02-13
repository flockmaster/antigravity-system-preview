import 'package:logger/logger.dart';

/// 应用全局日志工具类
/// 
/// 使用方法：
/// ```dart
/// AppLogger.d('调试信息');
/// AppLogger.i('普通信息');
/// AppLogger.w('警告信息');
/// AppLogger.e('错误信息', error: exception, stackTrace: stack);
/// ```
class AppLogger {
  // 私有构造器，防止实例化
  AppLogger._();

  // 单例 Logger 实例
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // 不显示调用栈
      errorMethodCount: 5, // 错误时显示5层调用栈
      lineLength: 80, // 每行最大长度
      colors: true, // 启用颜色
      printEmojis: true, // 启用表情符号
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // 显示时间
    ),
    level: Level.debug, // 设置最低日志级别
  );

  /// 调试日志 - 用于开发调试信息
  static void d(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 信息日志 - 用于一般信息输出
  static void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志 - 用于警告信息
  static void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志 - 用于错误信息
  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 严重错误日志 - 用于致命错误
  static void f(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 追踪日志 - 用于详细追踪
  static void t(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }
}
