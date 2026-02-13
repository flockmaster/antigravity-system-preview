import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'word.dart';

part 'dictation_session.g.dart';

/// Dictation Mode Enum
/// 
/// A: Hear English -> Write English
/// B: Hear Chinese -> Write English
/// C: Hear English -> Write Chinese
enum DictationMode {
  @JsonValue('MODE_A')
  modeA,
  @JsonValue('MODE_B')
  modeB,
  @JsonValue('MODE_C')
  modeC,
  @JsonValue('MODE_MIXED')
  modeMixed, // Generic Mixed (fallback)
  @JsonValue('MISTAKE_CRUSHER')
  mistakeCrusher,
  @JsonValue('SMART_REVIEW')
  smartReview,
  @JsonValue('CUSTOM_SELECTION')
  customSelection,
}

extension DictationModeExtension on DictationMode {
  String get label {
    switch (this) {
      case DictationMode.modeA: return '标准听写';
      case DictationMode.modeB: return '中译英';
      case DictationMode.modeC: return '听音释义';
      case DictationMode.modeMixed: return '综合练习';
      case DictationMode.mistakeCrusher: return '错题攻克';
      case DictationMode.smartReview: return '智能复习';
      case DictationMode.customSelection: return '自选练习';
    }
  }

  String get subtitle {
    switch (this) {
      case DictationMode.modeA: return '听英语 → 写英语';
      case DictationMode.modeB: return '听中文 → 写英语';
      case DictationMode.modeC: return '听英语 → 写中文';
      case DictationMode.modeMixed: return '全方位强化复习';
      case DictationMode.mistakeCrusher: return '消灭历史顽固错题';
      case DictationMode.smartReview: return '艾宾浩斯智能推荐';
      case DictationMode.customSelection: return '我的词库自由组合';
    }
  }

  Color get color {
    switch (this) {
      case DictationMode.modeA: return const Color(0xFFEDE9FE); // violet-100
      case DictationMode.modeB: return const Color(0xFFFFEDD5); // orange-100
      case DictationMode.modeC: return const Color(0xFFD1FAE5); // emerald-100
      case DictationMode.modeMixed: return const Color(0xFFF1F5F9); // slate-100
      case DictationMode.mistakeCrusher: return const Color(0xFFFFEDD5); // orange-100 (同modeB)
      case DictationMode.smartReview: return const Color(0xFFEDE9FE); // violet-100 (同modeA)
      case DictationMode.customSelection: return const Color(0xFFD1FAE5); // emerald-100 (同modeC)
    }
  }

  Color get iconColor {
    switch (this) {
      case DictationMode.modeA: return const Color(0xFF7C3AED); // violet-600
      case DictationMode.modeB: return const Color(0xFFEA580C); // orange-600
      case DictationMode.modeC: return const Color(0xFF059669); // emerald-600
      case DictationMode.modeMixed: return const Color(0xFF0F172A); // slate-900 (Black)
      case DictationMode.mistakeCrusher: return const Color(0xFFEA580C); // orange-600 (同modeB)
      case DictationMode.smartReview: return const Color(0xFF7C3AED); // violet-600 (同modeA)
      case DictationMode.customSelection: return const Color(0xFF059669); // emerald-600 (同modeC)
    }
  }
}

/// Helper to parse mode from string safely
DictationMode parseDictationMode(String? value) {
  if (value == null) return DictationMode.modeA;
  final normalized = value.toLowerCase().replaceAll('_', ''); // remove underscores
  
  if (normalized.contains('modea')) return DictationMode.modeA;
  if (normalized.contains('modeb')) return DictationMode.modeB;
  if (normalized.contains('modec')) return DictationMode.modeC;
  
  // Specific mixed modes
  if (normalized.contains('mistake')) return DictationMode.mistakeCrusher; // matches 'mistakecrusher'
  if (normalized.contains('smart')) return DictationMode.smartReview; // matches 'smartreview'
  if (normalized.contains('custom') || normalized.contains('selection')) return DictationMode.customSelection;
  
  // Fallback
  if (normalized.contains('mixed')) return DictationMode.modeMixed;
  
  return DictationMode.modeA;
}

/// Dictation Item
/// 
/// Represents a single question in a dictation session.
/// Wraps a Word with a specific Mode.
class DictationItem {
  final Word word;
  final DictationMode mode;
  /// Unique ID for this item (e.g. wordId_modeA) to distinguish duplicates in queue
  final String id; 

  const DictationItem({
    required this.id,
    required this.word,
    required this.mode,
  });
}


/// Mistake Model
/// 
/// Represents an item result (correct or incorrect) during a dictation session.
@JsonSerializable()
class Mistake {
  /// The target correct word
  final String word;

  /// The input provided by the student (can be null if skipped/empty)
  @JsonKey(name: 'student_input')
  final String? studentInput;

  /// Whether the input was judged as correct
  @JsonKey(name: 'is_correct')
  final bool isCorrect;
  
  /// The mode in which this mistake occurred
  final DictationMode? mode;

  /// The ID of the word (optional, for linking)
  final String? wordId;

  /// The correct/standard answer (optional, for Mode C or display)
  @JsonKey(name: 'correct_answer')
  final String? correctAnswer;

  const Mistake({
    required this.word,
    this.studentInput,
    required this.isCorrect,
    this.mode,
    this.wordId,
    this.correctAnswer,
  });

  factory Mistake.fromJson(Map<String, dynamic> json) => _$MistakeFromJson(json);

  Map<String, dynamic> toJson() => _$MistakeToJson(this);
}

/// Session Result Model
/// 
/// Contains the final score and details of a finished session.
@JsonSerializable()
class SessionResult {
  /// Unique session ID
  @JsonKey(name: 'session_id')
  final String sessionId;

  /// Total score (0-100)
  final int score;

  /// Total number of words in the session
  final int total;

  /// List of mistakes made (backward compatibility)
  final List<Mistake> mistakes;

  /// List of ALL items in the session (new feature)
  @JsonKey(name: 'all_items')
  final List<Mistake>? allItems;
  
  /// Base points (通过即得分: 通过数)
  @JsonKey(name: 'base_points', defaultValue: 0)
  final int basePoints;
  
  /// Combo bonus (连击奖励: firstTryCount / 3)
  @JsonKey(name: 'combo_bonus', defaultValue: 0)
  final int comboBonus;
  
  /// Points earned in this session (总分: basePoints + comboBonus)
  @JsonKey(name: 'points_earned')
  final int pointsEarned;

  /// Time spent in seconds
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  
  /// Extra stats (e.g. { 'modeA_total': 5, 'modeB_total': 5 })
  final Map<String, int>? stats;

  const SessionResult({
    required this.sessionId,
    required this.score,
    required this.total,
    required this.mistakes,
    this.allItems,
    this.basePoints = 0,
    this.comboBonus = 0,
    this.pointsEarned = 0,
    this.durationSeconds,
    this.stats,
  });

  factory SessionResult.fromJson(Map<String, dynamic> json) => _$SessionResultFromJson(json);

  Map<String, dynamic> toJson() => _$SessionResultToJson(this);
}

/// Dictation Session Model
/// 
/// Represents a dictation session history record.
@JsonSerializable()
class DictationSession {
  @JsonKey(name: 'session_id')
  final String sessionId;

  final DictationMode mode;

  /// ISO 8601 Date string
  final String date;

  final List<Word> words;

  const DictationSession({
    required this.sessionId,
    required this.mode,
    required this.date,
    required this.words,
  });

  factory DictationSession.fromJson(Map<String, dynamic> json) => _$DictationSessionFromJson(json);

  Map<String, dynamic> toJson() => _$DictationSessionToJson(this);
}
