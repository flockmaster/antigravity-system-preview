import 'package:json_annotation/json_annotation.dart';

part 'word.g.dart';

/// SQLite 整数到布尔值的转换器
class IntToBoolConverter implements JsonConverter<bool, dynamic> {
  const IntToBoolConverter();

  @override
  bool fromJson(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  @override
  int toJson(bool value) => value ? 1 : 0;
}

/// Word Model - 表示一个词汇单词
/// 
/// 基于原型的 `Word` 接口。
/// 
/// ## 智能推荐分数系统
/// - 使用持久化的 `recommendationScore` 进行推荐排序
/// - 分数越高，推荐优先级越高
/// - 分数在听写/阶梯学习完成后实时更新
@JsonSerializable()
class Word {
  /// 单词唯一标识符
  final String id;

  /// 英文单词本身 (例如 "apple")
  final String word;

  /// 来源图片ID（如果是扫描获取）
  final String? sourceImageId;

  /// 音标 (例如 "/ˈæp.l/")
  final String phonetic;

  /// 完整释义（用于学习/展示）
  @JsonKey(name: 'meaning_full')
  final String meaningFull;

  /// 听写用简化释义 (例如 "苹果")
  @JsonKey(name: 'meaning_for_dictation')
  final String meaningForDictation;

  /// 包含该单词的例句
  @JsonKey(defaultValue: '')
  final String sentence;

  /// 记忆法 (例如 "Pest -> 拍死它 -> 害虫")
  @JsonKey(defaultValue: '')
  final String mnemonic;

  // ============ 毕业状态 ============

  /// 是否毕业（听写全对过）
  /// - true: 已通过完整听写（Mode A+B+C 都对）
  /// - false: 尚未毕业或曾答错
  @JsonKey(name: 'is_graduated', defaultValue: false)
  @IntToBoolConverter()
  final bool isGraduated;

  /// 首次毕业时间（里程碑记录）
  @JsonKey(name: 'first_mastered_at')
  final DateTime? firstMasteredAt;

  // ============ 智能推荐字段 ============

  /// 推荐分数（持久化）
  /// - 分数越高，推荐优先级越高
  /// - 由各触发点实时更新
  @JsonKey(name: 'recommendation_score', defaultValue: 0.0)
  final double recommendationScore;

  /// 最后复习时间（听写或阶梯学习都会更新）
  @JsonKey(name: 'last_reviewed_at')
  final DateTime? lastReviewedAt;

  /// 最后阶梯学习完成时间（用于6小时冷却期）
  @JsonKey(name: 'last_learning_session_at')
  final DateTime? lastLearningSessionAt;

  /// 分数最后更新时间（用于判断是否需要每日刷新）
  @JsonKey(name: 'score_updated_at')
  final DateTime? scoreUpdatedAt;

  /// [New] 首次学习时间（用于精准统计每日新词进度）
  /// 当 totalReviews 从 0 变为 1 时记录此时间
  @JsonKey(name: 'first_learned_at')
  final DateTime? firstLearnedAt;

  // ============ 历史统计 ============

  /// 历史错误次数（顽固度指标，只增不减）
  @JsonKey(name: 'wrong_count', defaultValue: 0)
  final int wrongCount;

  /// 是否在错题本中（动态状态）
  /// - true: 当前在错题本中（最近一次答错）
  /// - false: 已移出错题本（最近一次答对）
  @JsonKey(name: 'is_in_mistake_book', defaultValue: false)
  @IntToBoolConverter()
  final bool isInMistakeBook;

  /// 总复习次数
  @JsonKey(name: 'total_reviews', defaultValue: 0)
  final int totalReviews;

  // ============ 跟读功能 ============

  /// 用户跟读录音路径
  @JsonKey(name: 'shadowing_url')
  final String? shadowingUrl;

  /// 跟读尝试次数
  @JsonKey(name: 'shadowing_attempts', defaultValue: 0)
  final int shadowingAttempts;

  // ============ 云同步字段 ============
  
  /// 最后修改时间戳 (Unix Ms)
  @JsonKey(name: 'last_modified')
  final int? lastModified;
  
  /// 同步状态（是否已同步到云端）
  @JsonKey(name: 'is_synced', defaultValue: false)
  @IntToBoolConverter()
  final bool isSynced;

  // ============ 多词书支持 ============

  /// 所属词书 ID (例如 "user_default" 或 "ket_core")
  @JsonKey(name: 'book_id', defaultValue: 'user_default')
  final String bookId;

  // ============ 便捷属性 ============

  /// 兼容旧代码的 isMastered 属性（等同于 isGraduated）
  bool get isMastered => isGraduated;

  /// 是否需要复习（基于遗忘曲线）
  bool get needsReview {
    if (!isGraduated) return false; // 未毕业的不算"需要复习"，而是"仍在学习"
    if (lastReviewedAt == null) return true;

    final daysSinceReview = DateTime.now().difference(lastReviewedAt!).inDays;
    
    // 简化的间隔复习逻辑：
    // 毕业后根据距上次复习天数判断
    // 超过3天就建议复习
    return daysSinceReview >= 3;
  }

  const Word({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.meaningFull,
    required this.meaningForDictation,
    required this.sentence,
    this.sourceImageId,
    this.mnemonic = '',
    this.isGraduated = false,
    this.firstMasteredAt,
    this.recommendationScore = 0.0,
    this.lastReviewedAt,
    this.lastLearningSessionAt,
    this.scoreUpdatedAt,
    this.firstLearnedAt,
    this.wrongCount = 0,
    this.isInMistakeBook = false,
    this.totalReviews = 0,
    this.shadowingUrl,
    this.shadowingAttempts = 0,
    this.lastModified,
    this.isSynced = false,
    this.bookId = 'user_default',
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  Map<String, dynamic> toJson() => _$WordToJson(this);

  /// 创建带有更新字段的副本
  Word copyWith({
    String? id,
    String? word,
    String? phonetic,
    String? meaningFull,
    String? meaningForDictation,
    String? sentence,
    String? sourceImageId,
    String? mnemonic,
    bool? isGraduated,
    DateTime? firstMasteredAt,
    double? recommendationScore,
    DateTime? lastReviewedAt,
    DateTime? lastLearningSessionAt,
    DateTime? scoreUpdatedAt,
    DateTime? firstLearnedAt,
    int? wrongCount,
    bool? isInMistakeBook,
    int? totalReviews,
    String? shadowingUrl,
    int? shadowingAttempts,
    int? lastModified,
    bool? isSynced,
    String? bookId,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      meaningFull: meaningFull ?? this.meaningFull,
      meaningForDictation: meaningForDictation ?? this.meaningForDictation,
      sentence: sentence ?? this.sentence,
      sourceImageId: sourceImageId ?? this.sourceImageId,
      mnemonic: mnemonic ?? this.mnemonic,
      isGraduated: isGraduated ?? this.isGraduated,
      firstMasteredAt: firstMasteredAt ?? this.firstMasteredAt,
      recommendationScore: recommendationScore ?? this.recommendationScore,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      lastLearningSessionAt: lastLearningSessionAt ?? this.lastLearningSessionAt,
      scoreUpdatedAt: scoreUpdatedAt ?? this.scoreUpdatedAt,
      firstLearnedAt: firstLearnedAt ?? this.firstLearnedAt,
      wrongCount: wrongCount ?? this.wrongCount,
      isInMistakeBook: isInMistakeBook ?? this.isInMistakeBook,
      totalReviews: totalReviews ?? this.totalReviews,
      shadowingUrl: shadowingUrl ?? this.shadowingUrl,
      shadowingAttempts: shadowingAttempts ?? this.shadowingAttempts,
      lastModified: lastModified ?? this.lastModified,
      isSynced: isSynced ?? this.isSynced,
      bookId: bookId ?? this.bookId,
    );
  }
}
