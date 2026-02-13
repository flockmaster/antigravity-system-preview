import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/models/dictation_session.dart';
import '../../../core/services/dictation_service.dart';

/// 模式选择视图模型
class ModeSelectionViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dictationService = locator<DictationService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_dictationService];

  /// 当前输入方式 (paper: 纸笔, digital: 手机)
  String get inputMethod => _dictationService.inputMethod;

  /// 切换输入方式
  void setInputMethod(String method) {
    _dictationService.setInputMethod(method);
  }

  /// 选择听写模式并开始
  void selectMode(DictationMode mode) {
    _dictationService.setMode(mode);
    // 强制乱序，确保听写效果
    _dictationService.shuffleWords();
    
    // inputMethod is already set in the service
    _navigationService.navigateToDictationView();
  }
}

