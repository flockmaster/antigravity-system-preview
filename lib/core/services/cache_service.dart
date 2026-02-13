import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/app_logger.dart';

abstract class ICacheService {
  Future<String> getCacheSize();
  Future<void> clearCache();
}

@LazySingleton(as: ICacheService)
class CacheService implements ICacheService {
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  @override
  Future<String> getCacheSize() async {
    try {
      int totalSize = 0;
      
      // 从 DefaultCacheManager 计算大小（通常在临时目录下）
      // DefaultCacheManager 将文件存储在 getTemporaryDirectory() / libCachedImageData
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/libCachedImageData');
      
      if (await cacheDir.exists()) {
        await for (var file in cacheDir.list(recursive: true, followLinks: false)) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      
      // 如果需要，也可以包含标准临时缓存，但有风险。
      // 根据要求，我们现在主要关注图片缓存。
      
      return _formatSize(totalSize);
    } catch (e) {
      AppLogger.e('计算缓存大小时出错', error: e);
      return '0 B';
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      
      // 手动清理目录以确保安全
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/libCachedImageData');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      AppLogger.e('清理缓存时出错', error: e);
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
