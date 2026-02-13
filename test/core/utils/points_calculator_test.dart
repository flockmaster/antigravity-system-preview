import 'package:flutter_test/flutter_test.dart';
import 'package:word_assistant/core/utils/points_calculator.dart';

void main() {
  group('PointsCalculator Tests', () {
    test('全对情况 (Perfect Score)', () {
      // 10个词，全对
      // Base: 10
      // FirstTry: 10 -> 10/3 = 3
      // Total: 13
      final result = PointsCalculator.calculate(totalWords: 10, errorCount: 0);
      expect(result.basePoints, 10);
      expect(result.comboBonus, 3);
      expect(result.totalPoints, 13);
    });

    test('错一个情况 (One Mistake)', () {
      // 10个词，错1个
      // Base: 10
      // FirstTry: 9 -> 9/3 = 3
      // Total: 13
      // 注：即使错了一个，FirstTry=9依然能凑齐3组Combo，体现了宽容性
      final result = PointsCalculator.calculate(totalWords: 10, errorCount: 1);
      expect(result.basePoints, 10);
      expect(result.comboBonus, 3);
      expect(result.totalPoints, 13);
    });

    test('错两个情况 (Two Mistakes)', () {
      // 10个词，错2个
      // Base: 10
      // FirstTry: 8 -> 8/3 = 2
      // Total: 12
      final result = PointsCalculator.calculate(totalWords: 10, errorCount: 2);
      expect(result.basePoints, 10);
      expect(result.comboBonus, 2);
      expect(result.totalPoints, 12);
    });

    test('全错情况 (All Mistakes)', () {
      // 10个词，全错（但最终都修正通过）
      // Base: 10
      // FirstTry: 0 -> 0/3 = 0
      // Total: 10
      final result = PointsCalculator.calculate(totalWords: 10, errorCount: 10);
      expect(result.basePoints, 10);
      expect(result.comboBonus, 0);
      expect(result.totalPoints, 10);
    });

    test('短列表防御 (Short List)', () {
      // 2个词，全对
      // Base: 2
      // FirstTry: 2 -> 通常不够3，也是0。但如果逻辑没写好 short list防刷，这里主要测逻辑分支
      final result = PointsCalculator.calculate(totalWords: 2, errorCount: 0);
      expect(result.basePoints, 2);
      expect(result.comboBonus, 0); // Short list protection
      expect(result.totalPoints, 2);
    });

    test('恰好3个词全对 (Minimum Combo)', () {
      // 3个词，全对
      // Base: 3
      // FirstTry: 3 -> 1
      // Total: 4
      final result = PointsCalculator.calculate(totalWords: 3, errorCount: 0);
      expect(result.basePoints, 3);
      expect(result.comboBonus, 1);
      expect(result.totalPoints, 4);
    });

    test('输入边界防御 (Negative inputs)', () {
      final result = PointsCalculator.calculate(totalWords: -5, errorCount: -1);
      expect(result.basePoints, 0);
      expect(result.comboBonus, 0);
      expect(result.totalPoints, 0);
    });

    test('错误数大于总数防御 (Error > Total)', () {
      // 5个词，传了10个错（逻辑上不可能，但防御性编程）
      // 应视为 5 个错
      // Base: 5
      // FirstTry: 0
      final result = PointsCalculator.calculate(totalWords: 5, errorCount: 10);
      expect(result.basePoints, 5);
      expect(result.comboBonus, 0);
      expect(result.totalPoints, 5);
    });
    
    test('大规模测试 (Large List)', () {
      // 50个词，全对
      // Base: 50
      // Bonus: 50/3 = 16
      // Total: 66
      final result = PointsCalculator.calculate(totalWords: 50, errorCount: 0);
      expect(result.totalPoints, 66);
    });
  });
}
