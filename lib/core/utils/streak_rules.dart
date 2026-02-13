class StreakRules {
  static const int validCheckinWordThreshold = 5;
  static const int goldTotalWordThreshold = 12;
  static const int goldPerModeWordThreshold = 3;
  static const int goldBonusPoints = 20;
  static const int retroCheckinCost = 200;
  static const int retroLimitPerMonth = 3;
  static const int retroLookbackDays = 30;
  static const String goldRewardType = 'gold_bonus';

  static String formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
