// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictation_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mistake _$MistakeFromJson(Map<String, dynamic> json) => Mistake(
      word: json['word'] as String,
      studentInput: json['student_input'] as String?,
      isCorrect: json['is_correct'] as bool,
      mode: $enumDecodeNullable(_$DictationModeEnumMap, json['mode']),
      wordId: json['wordId'] as String?,
      correctAnswer: json['correct_answer'] as String?,
    );

Map<String, dynamic> _$MistakeToJson(Mistake instance) => <String, dynamic>{
      'word': instance.word,
      'student_input': instance.studentInput,
      'is_correct': instance.isCorrect,
      'mode': _$DictationModeEnumMap[instance.mode],
      'wordId': instance.wordId,
      'correct_answer': instance.correctAnswer,
    };

const _$DictationModeEnumMap = {
  DictationMode.modeA: 'MODE_A',
  DictationMode.modeB: 'MODE_B',
  DictationMode.modeC: 'MODE_C',
  DictationMode.modeMixed: 'MODE_MIXED',
  DictationMode.mistakeCrusher: 'MISTAKE_CRUSHER',
  DictationMode.smartReview: 'SMART_REVIEW',
  DictationMode.customSelection: 'CUSTOM_SELECTION',
};

SessionResult _$SessionResultFromJson(Map<String, dynamic> json) =>
    SessionResult(
      sessionId: json['session_id'] as String,
      score: (json['score'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      mistakes: (json['mistakes'] as List<dynamic>)
          .map((e) => Mistake.fromJson(e as Map<String, dynamic>))
          .toList(),
      allItems: (json['all_items'] as List<dynamic>?)
          ?.map((e) => Mistake.fromJson(e as Map<String, dynamic>))
          .toList(),
      basePoints: (json['base_points'] as num?)?.toInt() ?? 0,
      comboBonus: (json['combo_bonus'] as num?)?.toInt() ?? 0,
      pointsEarned: (json['points_earned'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      stats: (json['stats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$SessionResultToJson(SessionResult instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'score': instance.score,
      'total': instance.total,
      'mistakes': instance.mistakes,
      'all_items': instance.allItems,
      'base_points': instance.basePoints,
      'combo_bonus': instance.comboBonus,
      'points_earned': instance.pointsEarned,
      'duration_seconds': instance.durationSeconds,
      'stats': instance.stats,
    };

DictationSession _$DictationSessionFromJson(Map<String, dynamic> json) =>
    DictationSession(
      sessionId: json['session_id'] as String,
      mode: $enumDecode(_$DictationModeEnumMap, json['mode']),
      date: json['date'] as String,
      words: (json['words'] as List<dynamic>)
          .map((e) => Word.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DictationSessionToJson(DictationSession instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'mode': _$DictationModeEnumMap[instance.mode]!,
      'date': instance.date,
      'words': instance.words,
    };
