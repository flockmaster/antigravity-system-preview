import 'package:json_annotation/json_annotation.dart';
import 'word.dart';

part 'learning_model.g.dart';

enum LearningStage {
  @JsonValue('preview')
  preview,
  @JsonValue('recognition')
  recognition,
  @JsonValue('readAloud')
  readAloud,    // 第2.5关：朗读跟读
  @JsonValue('recall')
  recall,       // 第3关：填空回想
  @JsonValue('construction')
  construction, // 第4关：拼写重组
  @JsonValue('dictation')
  dictation,
  @JsonValue('summary')
  summary,
}

extension LearningStageExtension on LearningStage {
  String get title {
    switch (this) {
      case LearningStage.preview: return '第1关：预习跟读';
      case LearningStage.recognition: return '第2关：听音选义';
      case LearningStage.readAloud: return '第2.5关：大声朗读';
      case LearningStage.recall: return '第3关：填空回想';
      case LearningStage.construction: return '第4关：拼写重组';
      case LearningStage.dictation: return 'Boss战：默写挑战';
      case LearningStage.summary: return '通关结算';
    }
  }

  int get progressStep {
    switch (this) {
      case LearningStage.preview: return 1;
      case LearningStage.recognition: return 2;
      case LearningStage.readAloud: return 3;
      case LearningStage.recall: return 4;
      case LearningStage.construction: return 5;
      case LearningStage.dictation: return 6;
      case LearningStage.summary: return 7;
    }
  }
}

@JsonSerializable()
class LearningSession {
  final String id;
  final List<Word> batch;
  
  @JsonKey(name: 'current_stage')
  final LearningStage currentStage;
  
  @JsonKey(name: 'current_index')
  final int currentIndex;
  
  /// List of word IDs that had errors in this session
  @JsonKey(name: 'error_word_ids')
  final Set<String> errorWordIds;

  @JsonKey(name: 'start_time')
  final DateTime? startTime;

  @JsonKey(name: 'session_source')
  final String? sessionSource;

  const LearningSession({
    required this.id,
    required this.batch,
    this.currentStage = LearningStage.preview,
    this.currentIndex = 0,
    this.errorWordIds = const {},
    this.startTime,
    this.sessionSource,
  });

  LearningSession copyWith({
    String? id,
    List<Word>? batch,
    LearningStage? currentStage,
    int? currentIndex,
    Set<String>? errorWordIds,
    DateTime? startTime,
    String? sessionSource,
  }) {
    return LearningSession(
      id: id ?? this.id,
      batch: batch ?? this.batch,
      currentStage: currentStage ?? this.currentStage,
      currentIndex: currentIndex ?? this.currentIndex,
      errorWordIds: errorWordIds ?? this.errorWordIds,
      startTime: startTime ?? this.startTime,
      sessionSource: sessionSource ?? this.sessionSource,
    );
  }

  factory LearningSession.fromJson(Map<String, dynamic> json) => _$LearningSessionFromJson(json);
  Map<String, dynamic> toJson() => _$LearningSessionToJson(this);
}
