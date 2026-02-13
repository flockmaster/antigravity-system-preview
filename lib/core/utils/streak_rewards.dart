import '../services/database_service.dart';
import '../services/user_service.dart';
import 'streak_rules.dart';
import '../models/dictation_session.dart';

class StreakRewards {
  static Future<bool> maybeGrantGoldBonusForDate({
    required DatabaseService dbService,
    required UserService userService,
    required DateTime date,
  }) async {
    final dateKey = StreakRules.formatDateKey(date);
    final eligible = await dbService.isGoldEligibleForDateKey(dateKey);
    if (!eligible) return false;

    final alreadyGranted = await dbService.hasDailyReward(dateKey, StreakRules.goldRewardType);
    if (alreadyGranted) return false;

    final inserted = await dbService.insertDailyReward(
      dateKey,
      StreakRules.goldRewardType,
      StreakRules.goldBonusPoints,
    );
    if (!inserted) return false;

    await userService.addPoints(StreakRules.goldBonusPoints);
    return true;
  }

  static bool isGoldEligibleFromCounts(Map<DictationMode, int> counts) {
    final a = counts[DictationMode.modeA] ?? 0;
    final b = counts[DictationMode.modeB] ?? 0;
    final c = counts[DictationMode.modeC] ?? 0;
    final total = a + b + c;
    return a >= StreakRules.goldPerModeWordThreshold &&
        b >= StreakRules.goldPerModeWordThreshold &&
        c >= StreakRules.goldPerModeWordThreshold &&
        total >= StreakRules.goldTotalWordThreshold;
  }
}
