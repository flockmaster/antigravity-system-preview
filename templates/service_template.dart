/// ============================================================================
/// 📄 Service 模板文件
/// ============================================================================
///
/// 用途: 创建新 Service 时的标准参考模板
/// 规则: 所有数据获取必须通过 ApiClient (铁律 #7)
///
/// 使用方法:
/// 1. 复制此文件到目标目录
/// 2. 重命名文件和类名
/// 3. 在 app.locator.dart 中注册此 Service
/// ============================================================================

import 'package:stacked/stacked.dart';
import '../lib/core/network/api_client.dart';
import '../lib/app/app.locator.dart';

// 导入相关的 Model
// import '../lib/core/models/example_model.dart';

/// [ExampleService] - 示例服务
///
/// 职责:
/// - 封装特定业务领域的数据操作
/// - 调用 ApiClient 获取/提交数据
/// - 处理数据转换和缓存逻辑
///
/// 注意事项:
/// - 禁止在 Service 中包含 Mock 逻辑 (铁律 #7)
/// - Mock 数据由 MockInterceptor 统一处理
class ExampleService with ListenableServiceMixin {
  // ============================================================================
  // 依赖注入
  // ============================================================================

  /// API 客户端 - 所有网络请求必须通过此发起 (铁律 #7)
  final ApiClient _apiClient = locator<ApiClient>();

  // ============================================================================
  // 响应式状态 (可选 - 用于跨 ViewModel 共享状态)
  // ============================================================================

  /// 示例: 响应式数据列表
  /// 当数据变化时，所有监听此 Service 的 ViewModel 会自动刷新
  final ReactiveValue<List<String>> _cachedItems = ReactiveValue<List<String>>([]);
  List<String> get cachedItems => _cachedItems.value;

  /// 示例: 加载状态
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);
  bool get isLoading => _isLoading.value;

  // ============================================================================
  // 构造函数
  // ============================================================================

  ExampleService() {
    // 注册响应式值，使其变化时通知监听者
    listenToReactiveValues([_cachedItems, _isLoading]);
  }

  // ============================================================================
  // 公开方法 (API)
  // ============================================================================

  /// 获取项目列表
  ///
  /// [page] 页码，从 1 开始
  /// [pageSize] 每页数量，默认 10
  ///
  /// 返回: 项目列表
  /// 异常: 网络错误时抛出 DioException
  Future<List<String>> fetchItems({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      _isLoading.value = true;
      notifyListeners();

      // 通过 ApiClient 发起请求 (铁律 #7)
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/items',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );

      // 解析响应数据
      final data = response.data;
      if (data != null && data['items'] is List) {
        final items = (data['items'] as List).map((e) => e.toString()).toList();
        
        // 更新缓存
        _cachedItems.value = items;
        notifyListeners();
        
        return items;
      }

      return [];
    } catch (e) {
      // 错误会向上传递给 ViewModel 处理
      rethrow;
    } finally {
      _isLoading.value = false;
      notifyListeners();
    }
  }

  /// 获取单个项目详情
  ///
  /// [id] 项目 ID
  ///
  /// 返回: 项目详情 (Map 格式，实际项目中应返回具体 Model)
  Future<Map<String, dynamic>?> fetchItemDetail(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/items/$id',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 创建新项目
  ///
  /// [data] 项目数据
  ///
  /// 返回: 创建成功的项目 ID
  Future<String?> createItem(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/items',
        data: data,
      );
      
      // 假设接口返回 { "id": "xxx" }
      return response.data?['id'] as String?;
    } catch (e) {
      rethrow;
    }
  }

  /// 更新项目
  ///
  /// [id] 项目 ID
  /// [data] 更新数据
  Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await _apiClient.post<void>(
        '/items/$id',
        data: data,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // 私有方法
  // ============================================================================

  /// 清除缓存
  void clearCache() {
    _cachedItems.value = [];
    notifyListeners();
  }

  // ============================================================================
  // 资源释放
  // ============================================================================

  /// 释放资源
  /// 如果 Service 被单例管理 (通常情况)，此方法可能不会被调用
  void dispose() {
    // 清理资源
    clearCache();
  }
}

// ============================================================================
// Locator 注册示例
// ============================================================================
//
// 在 app.locator.dart 中添加:
//
// locator.registerLazySingleton<ExampleService>(() => ExampleService());
//
// 然后在 ViewModel 中注入:
//
// final ExampleService _exampleService = locator<ExampleService>();
//
// 如果需要监听 Service 变化:
//
// @override
// List<ListenableServiceMixin> get listenableServices => [_exampleService];
