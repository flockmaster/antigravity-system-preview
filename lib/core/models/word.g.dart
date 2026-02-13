// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
      id: json['id'] as String,
      word: json['word'] as String,
      phonetic: json['phonetic'] as String,
      meaningFull: json['meaning_full'] as String,
      meaningForDictation: json['meaning_for_dictation'] as String,
      sentence: json['sentence'] as String? ?? '',
      sourceImageId: json['sourceImageId'] as String?,
      mnemonic: json['mnemonic'] as String? ?? '',
      isGraduated: json['is_graduated'] == null
          ? false
          : const IntToBoolConverter().fromJson(json['is_graduated']),
      firstMasteredAt: json['first_mastered_at'] == null
          ? null
          : DateTime.parse(json['first_mastered_at'] as String),
      recommendationScore:
          (json['recommendation_score'] as num?)?.toDouble() ?? 0.0,
      lastReviewedAt: json['last_reviewed_at'] == null
          ? null
          : DateTime.parse(json['last_reviewed_at'] as String),
      lastLearningSessionAt: json['last_learning_session_at'] == null
          ? null
          : DateTime.parse(json['last_learning_session_at'] as String),
      scoreUpdatedAt: json['score_updated_at'] == null
          ? null
          : DateTime.parse(json['score_updated_at'] as String),
      firstLearnedAt: json['first_learned_at'] == null
          ? null
          : DateTime.parse(json['first_learned_at'] as String),
      wrongCount: (json['wrong_count'] as num?)?.toInt() ?? 0,
      isInMistakeBook: json['is_in_mistake_book'] == null
          ? false
          : const IntToBoolConverter().fromJson(json['is_in_mistake_book']),
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      shadowingUrl: json['shadowing_url'] as String?,
      shadowingAttempts: (json['shadowing_attempts'] as num?)?.toInt() ?? 0,
      lastModified: (json['last_modified'] as num?)?.toInt(),
      isSynced: json['is_synced'] == null
          ? false
          : const IntToBoolConverter().fromJson(json['is_synced']),
      bookId: json['book_id'] as String? ?? 'user_default',
    );

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'sourceImageId': instance.sourceImageId,
      'phonetic': instance.phonetic,
      'meaning_full': instance.meaningFull,
      'meaning_for_dictation': instance.meaningForDictation,
      'sentence': instance.sentence,
      'mnemonic': instance.mnemonic,
      'is_graduated': const IntToBoolConverter().toJson(instance.isGraduated),
      'first_mastered_at': instance.firstMasteredAt?.toIso8601String(),
      'recommendation_score': instance.recommendationScore,
      'last_reviewed_at': instance.lastReviewedAt?.toIso8601String(),
      'last_learning_session_at':
          instance.lastLearningSessionAt?.toIso8601String(),
      'score_updated_at': instance.scoreUpdatedAt?.toIso8601String(),
      'first_learned_at': instance.firstLearnedAt?.toIso8601String(),
      'wrong_count': instance.wrongCount,
      'is_in_mistake_book':
          const IntToBoolConverter().toJson(instance.isInMistakeBook),
      'total_reviews': instance.totalReviews,
      'shadowing_url': instance.shadowingUrl,
      'shadowing_attempts': instance.shadowingAttempts,
      'last_modified': instance.lastModified,
      'is_synced': const IntToBoolConverter().toJson(instance.isSynced),
      'book_id': instance.bookId,
    };
