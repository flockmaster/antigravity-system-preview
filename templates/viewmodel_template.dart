/// ============================================================================
/// 📄 ViewModel 模板文件
/// ============================================================================
/// 
/// 用途: 创建新 ViewModel 时的标准参考模板
/// 规则: 所有 ViewModel 必须继承 BaicBaseViewModel (铁律 #1)
/// 
/// 使用方法:
/// 1. 复制此文件到目标目录
/// 2. 重命名文件和类名
/// 3. 根据业务需求修改状态和方法
/// ============================================================================

import '../lib/core/base/baic_base_view_model.dart';
import '../lib/app/app.locator.dart';
// import '../lib/app/app.router.dart'; // 待路由生成后启用

/// [ExampleViewModel] - 示例 ViewModel
/// 
/// 继承自 [BaicBaseViewModel]，自动获得以下能力:
/// - NavigationService: 通过 MapsTo() 和 goBack() 进行导航
/// - DialogService: 通过 showInfo() 显示弹窗
/// - ReactiveViewModel: 通过 setBusy/setError 管理状态
class ExampleViewModel extends BaicBaseViewModel {
  
  // ============================================================================
  // 服务注入区 (在构造函数之前声明)
  // ============================================================================
  
  // 示例: 注入自定义服务
  // final MyService _myService = locator<MyService>();
  
  // ============================================================================
  // 状态变量区 (State)
  // ============================================================================
  
  /// 页面标题
  String _title = '页面标题';
  String get title => _title;
  
  /// 数据列表
  List<String> _items = [];
  List<String> get items => _items;
  
  /// 当前选中索引 (-1 表示未选中)
  int _selectedIndex = -1;
  int get selectedIndex => _selectedIndex;
  
  // ============================================================================
  // 生命周期方法
  // ============================================================================
  
  /// 当 View 首次构建完成后调用
  /// 适合执行初始化数据加载、权限检查等
  @override
  void onFutureError(dynamic error, Object? key) {
    // 统一处理 runBusyFuture 抛出的错误
    super.onFutureError(error, key);
    // 可以在这里记录日志或显示错误提示
    // showInfo('错误', error.toString());
  }
  
  /// 初始化方法 - 推荐在 ViewModelBuilder.onViewModelReady 中调用
  Future<void> initialise() async {
    await _loadData();
  }
  
  /// 当 ViewModel 被销毁前调用
  /// 适合执行资源释放、取消订阅等
  @override
  void dispose() {
    // 释放资源
    // _subscription?.cancel();
    // _controller?.dispose();
    super.dispose();
  }
  
  // ============================================================================
  // 业务逻辑方法 (Public)
  // ============================================================================
  
  /// 刷新数据
  /// 
  /// 使用 runBusyFuture 自动管理 busy 状态
  Future<void> refreshData() async {
    await runBusyFuture(_loadData(), busyObject: 'refresh');
  }
  
  /// 选择某个项目
  void selectItem(int index) {
    if (index < 0 || index >= _items.length) return;
    
    _selectedIndex = index;
    rebuildUi(); // 通知 UI 刷新
  }
  
  /// 导航到详情页
  /// 
  /// 使用 MapsTo 进行导航，遵守铁律 #1
  Future<void> goToDetail(String itemId) async {
    // 示例: 导航到详情页，并传递参数
    // await MapsTo(Routes.detailView, arguments: DetailViewArguments(id: itemId));
    
    // 临时占位
    showInfo('提示', '将跳转到详情页: $itemId');
  }
  
  /// 返回上一页
  /// 
  /// 使用 goBack 进行返回，遵守铁律 #1
  void handleBack() {
    goBack();
  }
  
  // ============================================================================
  // 私有方法 (Private)
  // ============================================================================
  
  /// 加载数据
  Future<void> _loadData() async {
    // 示例: 调用 API 获取数据
    // final response = await _myService.fetchItems();
    // _items = response;
    
    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));
    _items = ['项目 1', '项目 2', '项目 3'];
    
    rebuildUi();
  }
  
  /// 验证数据
  bool _validateData() {
    if (_items.isEmpty) {
      setError(Exception('没有可用的数据'));
      return false;
    }
    return true;
  }
  
  // ============================================================================
  // Reactive Services (如需监听 Service 变化)
  // ============================================================================
  
  // 如果需要监听某个 Service 的变化，重写此方法
  // @override
  // List<ListenableServiceMixin> get listenableServices => [_myReactiveService];
}