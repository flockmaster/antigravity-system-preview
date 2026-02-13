class PointsCalculator {
  /// 计算积分详情
  ///
  /// [totalWords] 总单词数 (通常等于通过的单词数)
  /// [errorCount] 错误单词数 (错误列表的长度)
  static PointsCalculationResult calculate({
    required int totalWords,
    required int errorCount,
  }) {
    // 防御性检查
    if (totalWords < 0) totalWords = 0;
    if (errorCount < 0) errorCount = 0;
    if (errorCount > totalWords) errorCount = totalWords;

    // 1. 基础分: 只要通过就得分 (修正即得分)
    final int basePoints = totalWords;

    // 2. 连击奖励 (Combo Bonus)
    // 规则: 每 3 个 First Try (未进入错误列表) 的单词，得 1 分
    final int firstTryCount = totalWords - errorCount;
    
    int comboBonus = 0;
    // 防御: 短列表 (少于3个词) 不触发 Combo，防止刷分
    if (totalWords >= 3) {
      comboBonus = (firstTryCount / 3).floor();
    }

    final int totalPoints = basePoints + comboBonus;

    return PointsCalculationResult(
      basePoints: basePoints,
      comboBonus: comboBonus,
      totalPoints: totalPoints,
    );
  }
}

/// 积分计算结果模型
class PointsCalculationResult {
  final int basePoints;
  final int comboBonus;
  final int totalPoints;

  const PointsCalculationResult({
    required this.basePoints,
    required this.comboBonus,
    required this.totalPoints,
  });

  @override
  String toString() {
    return 'PointsCalculationResult(base: $basePoints, bonus: $comboBonus, total: $totalPoints)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PointsCalculationResult &&
        other.basePoints == basePoints &&
        other.comboBonus == comboBonus &&
        other.totalPoints == totalPoints;
  }

  @override
  int get hashCode => Object.hash(basePoints, comboBonus, totalPoints);
}
