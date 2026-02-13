import 'package:stacked/stacked.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// 用户服务
/// 
/// 管理用户信息，包括昵称、积分等。
class UserService with ListenableServiceMixin {
  static const String _keyNickname = 'user_nickname';
  static const String _keyPoints = 'user_points';

  String _nickname = 'Olivia';
  String get nickname => _nickname;

  int _points = 0;
  int get points => _points;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _nickname = prefs.getString(_keyNickname) ?? 'Olivia';
      _points = prefs.getInt(_keyPoints) ?? 0;
      notifyListeners();
    } catch (e) {
      AppLogger.e('初始化 UserService 失败', error: e);
    }
  }

  Future<void> updateNickname(String newNickname) async {
    _nickname = newNickname;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, newNickname);
    notifyListeners();
  }

  /// 增加积分
  Future<void> addPoints(int amount) async {
    if (amount <= 0) return;
    _points += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, _points);
    AppLogger.i('积分增加: $amount, 当前总积分: $_points');
    notifyListeners();
  }

  /// 消耗积分 (预留)
  Future<bool> consumePoints(int amount) async {
    if (_points < amount) return false;
    _points -= amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, _points);
    notifyListeners();
    return true;
  }
}
