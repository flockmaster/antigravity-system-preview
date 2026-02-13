import 'package:json_annotation/json_annotation.dart';

part 'study_stat.g.dart';

@JsonSerializable()
class StudyStat {
  final int? id;
  final String date; // yyyy-MM-dd
  
  @JsonKey(name: 'session_type')
  final String sessionType;
  
  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;
  
  @JsonKey(name: 'word_count')
  final int wordCount;
  
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  
  @JsonKey(name: 'end_time')
  final DateTime endTime;

  StudyStat({
    this.id,
    required this.date,
    required this.sessionType,
    required this.durationSeconds,
    required this.wordCount,
    required this.startTime,
    required this.endTime,
  });

  factory StudyStat.fromJson(Map<String, dynamic> json) => _$StudyStatFromJson(json);
  Map<String, dynamic> toJson() => _$StudyStatToJson(this);
}
