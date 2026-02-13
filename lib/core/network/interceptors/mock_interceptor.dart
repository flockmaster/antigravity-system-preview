import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../../utils/app_logger.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 逻辑：如果 path 匹配到 mock 规则，则返回本地数据
    // 在商用场景下，可以通过开关配置
    const bool useMock = true; 

    if (useMock) {
      try {
        // 尝试从 assets/mock 目录读取对应的 json 文件
        // 例如 path 为 /user/profile -> assets/mock/user/profile.json
        String path = options.path;
        if (path.startsWith('/')) path = path.substring(1);
        
        // 处理 query parameters (可选，简单处理)
        if (path.contains('?')) {
          path = path.split('?')[0];
        }
        
        final String fileName = 'assets/mock/$path.json';
        
        // 模拟网络延迟
        await Future.delayed(const Duration(milliseconds: 500));

        // 注意：这里需要确保文件存在，否则会抛出异常进入 catch
        final String responseData = await rootBundle.loadString(fileName);
        final dynamic json = jsonDecode(responseData);

        handler.resolve(
          Response(
            requestOptions: options,
            data: json,
            statusCode: 200,
          ),
        );
        return;
      } catch (e) {
        // 如果找不到 mock 文件，则继续请求真实接口
        AppLogger.d('Mock file not found for path ${options.path}, proceeding to real API', error: e);
      }
    }
    
    super.onRequest(options, handler);
  }
}
