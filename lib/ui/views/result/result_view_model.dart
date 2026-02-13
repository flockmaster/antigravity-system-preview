import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/services/dictation_service.dart';
import '../../../core/models/dictation_session.dart';

class ResultViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dictationService = locator<DictationService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_dictationService];

  SessionResult? get result => _dictationService.lastResult;

  /// 积分直接从 SessionResult 读取 (SSOT: 不再本地计算)
  int get pointsEarned => result?.pointsEarned ?? 0;
  
  /// 基础分 (通过即得分)
  int get basePoints => result?.basePoints ?? 0;
  
  /// 连击奖励
  int get comboBonus => result?.comboBonus ?? 0;

  void goHome() {
    _navigationService.clearStackAndShow(Routes.mainView);
  }
}
