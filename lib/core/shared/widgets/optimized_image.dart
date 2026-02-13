import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:word_assistant/core/constants/app_constants.dart';

/// 优化的图片加载组件
/// 
/// 特性：
/// - 自动区分本地assets和网络图片
/// - 网络图片自动缓存（内存+磁盘）
/// - 渐进式加载动画
/// - 统一的错误处理
class OptimizedImage extends StatelessWidget {
  /// 图片路径（支持assets/和网络URL）
  final String imageUrl;
  
  /// 图片填充方式
  final BoxFit fit;
  
  /// 图片宽度
  final double? width;
  
  /// 图片高度
  final double? height;
  
  /// 圆角
  final BorderRadius? borderRadius;
  
  /// 占位符Widget（可选）
  final Widget? placeholder;
  
  /// 错误Widget（可选）
  final Widget? errorWidget;
  
  /// 淡入动画时长
  final Duration fadeInDuration;
  
  /// 内存缓存宽度（用于优化内存）
  final int? memCacheWidth;
  
  /// 内存缓存高度（用于优化内存）
  final int? memCacheHeight;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final String resolvedUrl = AppConstants.getImageUrl(imageUrl);
    
    Widget image;
    
    // 路径为空处理
    if (imageUrl.isEmpty || resolvedUrl == AppConstants.imageBaseUrl || resolvedUrl == '${AppConstants.imageBaseUrl}/') {
      return borderRadius != null 
          ? ClipRRect(borderRadius: borderRadius!, child: _buildPlaceholder())
          : _buildPlaceholder();
    }
    
    // 区分本地assets和网络图片
    if (resolvedUrl.startsWith('assets/')) {
      image = _buildAssetImage(resolvedUrl);
    } else {
      image = _buildNetworkImage(resolvedUrl);
    }
    
    // 应用圆角
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    
    return image;
  }

  /// 构建本地资源图片
  Widget _buildAssetImage(String assetPath) {
    return Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: memCacheWidth,
      cacheHeight: memCacheHeight,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  /// 构建网络图片（带缓存）
  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
  }

  /// 默认占位符
  Widget _buildPlaceholder() {
    return placeholder ?? Container(
      width: width,
      height: height,
      color: const Color(0xFFF5F5F5),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFCCCCCC),
          ),
        ),
      ),
    );
  }

  /// 默认错误Widget
  Widget _buildErrorWidget() {
    return errorWidget ?? Container(
      width: width,
      height: height,
      color: const Color(0xFFF0F0F0),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFFCCCCCC),
          size: 24,
        ),
      ),
    );
  }
}

/// 头像专用的优化图片组件
class OptimizedAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Widget? placeholder;

  const OptimizedAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
      memCacheWidth: (size * 2).toInt(), // 2x for retina
      memCacheHeight: (size * 2).toInt(),
      placeholder: placeholder ?? Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFE0E0E0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          size: size * 0.5,
          color: const Color(0xFF999999),
        ),
      ),
    );
  }
}

/// 缩略图专用组件（自动使用较小的缓存尺寸）
class OptimizedThumbnail extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const OptimizedThumbnail({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      // 缩略图使用较小的缓存尺寸以节省内存
      memCacheWidth: width != null ? (width! * 2).toInt() : 400,
      memCacheHeight: height != null ? (height! * 2).toInt() : 400,
    );
  }
}
