/// 数字格式化工具类
class NumberUtils {
  /// 格式化数值（如：15200 -> 15.2k）
  static String formatCount(dynamic count) {
    if (count == null) return '0';
    
    int value = 0;
    if (count is String) {
      // 尝试解析，如果已经是带后缀的字符串则直接返回（向下兼容）
      if (count.contains('k') || count.contains('m')) return count;
      value = int.tryParse(count) ?? 0;
    } else if (count is int) {
      value = count;
    } else if (count is double) {
      value = count.toInt();
    }

    if (value < 1000) {
      return value.toString();
    } else if (value < 1000000) {
      double k = value / 1000.0;
      // 如果正好是整数，则不带小数点
      if (value % 1000 == 0) return "${(value ~/ 1000)}k";
      return "${k.toStringAsFixed(1)}k";
    } else {
      double m = value / 1000000.0;
      if (value % 1000000 == 0) return "${(value ~/ 1000000)}m";
      return "${m.toStringAsFixed(1)}m";
    }
  }
}
