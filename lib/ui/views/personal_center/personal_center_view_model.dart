import '../../../app/app.router.dart';

import '../../../app/app.locator.dart';
import '../../../core/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/services/database_service.dart';
import '../../../core/models/sheet_action.dart';
import '../../../core/enums/bottom_sheet_type.dart';
import '../main/main_view_model.dart';

class PersonalCenterViewModel extends ReactiveViewModel {
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _databaseService = locator<DatabaseService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_userService, _databaseService];


  String get nickname => _userService.nickname;
  int get points => _userService.points;

  final String _avatarPath = "assets/images/avatar_boy.png";
  String get avatarPath => _avatarPath;


  Future<void> init() async {
    await _userService.init();
  }


  void navigateBack() {
    _navigationService.back();
  }


  Future<void> updateNickname() async {
    // 简单实现：轮换昵称（正式版应提供输入框）
    final newNickname = _userService.nickname == "Olivia" ? "User" : "Olivia";
    await _userService.updateNickname(newNickname);
  }


  Future<void> openTtsSettings() async {
    await _navigationService.navigateTo(Routes.ttsSettingsView);
  }


  void navigateToStatistics() {
    _navigationService.navigateTo(Routes.statisticsView);
  }

  void navigateToEmailSettings() {
    _navigationService.navigateTo(Routes.emailSettingsView);
  }


  void showComingSoon(String feature) {
    _dialogService.showDialog(
      title: '敬请期待',
      description: '$feature 功能正在开发中...',
    );
  }

  // 获取当前词书显示名称
  String get currentBookLabel {
    final id = _databaseService.currentBookId;
    if (id == 'user_default') return '我的生词本';
    if (id == 'ket_core') return 'KET核心词汇';
    return '未知词书';
  }

  // 显示切换词书弹窗
  Future<void> showBookSwitcher() async {
    final books = await _databaseService.getBooks();
    
    final result = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.list,
      title: '切换学习目标',
      description: '请选择您想要学习的词库',
      data: books.map((b) => SheetAction(
        title: '${b['name']} (${b['total_words']}词)', 
        data: b['id'],
      )).toList(),
      secondaryButtonTitle: '取消',
    );

    if (result != null && result.data != null) {
      await _databaseService.switchBook(result.data);
    }
  }

  void navigateToFormattedShop() {
    // Navigate to MainView -> Calendar Tab (Index 1) -> Shop Tab (Index 1 inside Calendar)
    MainViewModel.requestShopTab = true;
    _navigationService.clearStackAndShow(Routes.mainView);
  }

  void navigateToAbout() {
    _navigationService.navigateTo(Routes.aboutView);
  }
}
