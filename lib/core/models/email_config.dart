import 'package:json_annotation/json_annotation.dart';

part 'email_config.g.dart';

@JsonSerializable()
class EmailConfig {
  final String smtpServer;
  final int smtpPort;
  final String username;
  final String password; // Authorization Code
  final List<String> recipients;
  final bool isEnabled;

  const EmailConfig({
    this.smtpServer = 'smtp.126.com',
    this.smtpPort = 465, // SSL port
    this.username = 'flockmaster@126.com',
    this.password = 'flockmaster_lw81',
    this.recipients = const ['flockmaster@126.com', '346307295@qq.com'],
    this.isEnabled = true,
  });

  factory EmailConfig.fromJson(Map<String, dynamic> json) => _$EmailConfigFromJson(json);
  Map<String, dynamic> toJson() => _$EmailConfigToJson(this);

  EmailConfig copyWith({
    String? smtpServer,
    int? smtpPort,
    String? username,
    String? password,
    List<String>? recipients,
    bool? isEnabled,
  }) {
    return EmailConfig(
      smtpServer: smtpServer ?? this.smtpServer,
      smtpPort: smtpPort ?? this.smtpPort,
      username: username ?? this.username,
      password: password ?? this.password,
      recipients: recipients ?? this.recipients,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
