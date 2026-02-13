// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailConfig _$EmailConfigFromJson(Map<String, dynamic> json) => EmailConfig(
      smtpServer: json['smtpServer'] as String? ?? 'smtp.126.com',
      smtpPort: (json['smtpPort'] as num?)?.toInt() ?? 465,
      username: json['username'] as String? ?? 'flockmaster@126.com',
      password: json['password'] as String? ?? 'flockmaster_lw81',
      recipients: (json['recipients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['flockmaster@126.com', '346307295@qq.com'],
      isEnabled: json['isEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$EmailConfigToJson(EmailConfig instance) =>
    <String, dynamic>{
      'smtpServer': instance.smtpServer,
      'smtpPort': instance.smtpPort,
      'username': instance.username,
      'password': instance.password,
      'recipients': instance.recipients,
      'isEnabled': instance.isEnabled,
    };
