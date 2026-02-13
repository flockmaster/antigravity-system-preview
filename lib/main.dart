import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.locator.dart';
import 'core/services/database_service.dart';
import 'core/services/user_service.dart';
import 'core/utils/app_logger.dart';
// 应用程序主组件
import 'app/car_owner_app.dart';
import 'ui/setup/setup_bottom_sheet_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置首选屏幕方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 使系统 UI 透明（沉浸式/窄边框设计）
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent, 
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // 初始化 Stacked 定位器
  await setupLocator();
  setupBottomSheetUi();


  // 初始化用户服务
  await locator<UserService>().init();


  // 每日分数刷新检查
  await _checkDailyScoreRefresh();

  runApp(const DictationPalApp());
}

/// 检查并执行每日分数刷新
/// 
/// 确保推荐分数考虑时间遗忘因素
Future<void> _checkDailyScoreRefresh() async {
  try {
    final dbService = locator<DatabaseService>();
    if (await dbService.needsDailyRefresh()) {
      await dbService.refreshDailyScores();
      AppLogger.i('✅ 每日分数刷新完成');
    }
  } catch (e) {
    AppLogger.w('⚠️ 每日分数刷新失败: $e');
    // 不阻止 App 启动
  }
}