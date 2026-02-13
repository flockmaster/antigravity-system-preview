// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyStat _$StudyStatFromJson(Map<String, dynamic> json) => StudyStat(
      id: (json['id'] as num?)?.toInt(),
      date: json['date'] as String,
      sessionType: json['session_type'] as String,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      wordCount: (json['word_count'] as num).toInt(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
    );

Map<String, dynamic> _$StudyStatToJson(StudyStat instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'session_type': instance.sessionType,
      'duration_seconds': instance.durationSeconds,
      'word_count': instance.wordCount,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
    };
