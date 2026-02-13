import 'dart:io';
import 'package:flutter/material.dart';
import 'package:word_assistant/core/constants/app_constants.dart';

class ImageUtils {
  static ImageProvider getImageProvider(String url) {
    // 1. Convert path using AppConstants
    final fullUrl = AppConstants.getImageUrl(url);

    // 2. Determine type
    if (fullUrl.startsWith('http')) {
      return NetworkImage(fullUrl);
    } else if (fullUrl.startsWith('assets/')) {
      return AssetImage(fullUrl);
    } else if (fullUrl.startsWith('/')) {
      return FileImage(File(fullUrl));
    }
    
    // Fallback
    return NetworkImage(fullUrl);
  }
}
