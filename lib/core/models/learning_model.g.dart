// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningSession _$LearningSessionFromJson(Map<String, dynamic> json) =>
    LearningSession(
      id: json['id'] as String,
      batch: (json['batch'] as List<dynamic>)
          .map((e) => Word.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentStage:
          $enumDecodeNullable(_$LearningStageEnumMap, json['current_stage']) ??
              LearningStage.preview,
      currentIndex: (json['current_index'] as num?)?.toInt() ?? 0,
      errorWordIds: (json['error_word_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      sessionSource: json['session_source'] as String?,
    );

Map<String, dynamic> _$LearningSessionToJson(LearningSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'batch': instance.batch,
      'current_stage': _$LearningStageEnumMap[instance.currentStage]!,
      'current_index': instance.currentIndex,
      'error_word_ids': instance.errorWordIds.toList(),
      'start_time': instance.startTime?.toIso8601String(),
      'session_source': instance.sessionSource,
    };

const _$LearningStageEnumMap = {
  LearningStage.preview: 'preview',
  LearningStage.recognition: 'recognition',
  LearningStage.readAloud: 'readAloud',
  LearningStage.recall: 'recall',
  LearningStage.construction: 'construction',
  LearningStage.dictation: 'dictation',
  LearningStage.summary: 'summary',
};
