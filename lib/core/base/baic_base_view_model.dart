import 'package:flutter/foundation.dart'; // for @protected
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
// export '../../app/app.router.dart'; // 待生成后启用

/// [BaicBaseViewModel] - 所有 ViewModel 的父类
/// 强制注入服务，屏蔽 Context
/// 集成 ReactiveViewModel，子类可通过重写 [listenableServices] 自动监听服务
abstract class BaicBaseViewModel extends ReactiveViewModel {
  @override
  List<ListenableServiceMixin> get listenableServices => [];
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  // Protected Getters for Subclasses
  @protected
  NavigationService get navigationService => _navigationService;
  
  @protected
  DialogService get dialogService => _dialogService;

  /// 规则铁律：必须使用 MapsTo 进行页面跳转
  Future MapsTo(String routeName, {dynamic arguments}) async {
    return await _navigationService.navigateTo(routeName, arguments: arguments);
  }

  /// 封装返回
  void goBack({dynamic result}) {
    _navigationService.back(result: result);
  }

  /// 显示信息弹窗
  Future showInfo(String title, String description) async {
    return await _dialogService.showDialog(
      title: title,
      description: description,
    );
  }
}
