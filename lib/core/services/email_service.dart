import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import '../models/email_config.dart';
import '../models/dictation_session.dart';
import '../utils/app_logger.dart';

class EmailService with ListenableServiceMixin {
  static const String _storageKey = 'email_config_v2';
  EmailConfig _config = const EmailConfig();

  EmailConfig get config => _config;

  Future<void> init() async {
    await _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      try {
        _config = EmailConfig.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        AppLogger.e('Failed to load email config', error: e);
      }
    }
    notifyListeners();
  }

  Future<void> saveConfig(EmailConfig newConfig) async {
    _config = newConfig;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_config.toJson()));
    notifyListeners();
  }

  Future<bool> sendTestEmail(String testRecipient) async {
    if (_config.username.isEmpty || _config.password.isEmpty) {
      throw Exception('请先配置发件人邮箱和密码/授权码');
    }
    
    return _sendEmail(
      subject: '单词助手 - 邮件测试',
      htmlContent: '<h1>邮件配置成功！</h1><p>这是一封测试邮件，如果您收到此邮件，说明您的SMTP配置正确。</p>',
      recipients: [testRecipient],
    );
  }

  Future<void> sendSessionReport(DictationSession session, SessionResult result) async {
    if (!_config.isEnabled || _config.recipients.isEmpty) return;
    
    // Construct HTML Report
    final html = _generateReportHtml(session, result);
    final subject = '单词助手学习报告: ${session.mode.label} - ${_formatDate(DateTime.now())}';
    
    await _sendEmail(
      subject: subject,
      htmlContent: html,
      recipients: _config.recipients,
    );
  }

  Future<bool> _sendEmail({
    required String subject,
    required String htmlContent,
    required List<String> recipients,
  }) async {
    final smtpServer = SmtpServer(
      _config.smtpServer,
      port: _config.smtpPort,
      username: _config.username,
      password: _config.password,
      ssl: _config.smtpPort == 465, // Assume SSL for 465
      ignoreBadCertificate: false,
    );

    final message = Message()
      ..from = Address(_config.username, '单词助手')
      ..recipients.addAll(recipients)
      ..subject = subject
      ..html = htmlContent;

    try {
      final sendReport = await send(message, smtpServer);
      AppLogger.i('Email sent: $sendReport');
      return true;
    } catch (e) {
      AppLogger.e('Message not sent.', error: e);
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour}:${date.minute}';
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '未知';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '$m分$s秒';
    return '$s秒';
  }

  String _generateReportHtml(DictationSession session, SessionResult result) {
    final perfect = result.score == 100;
    final color = perfect ? '#10B981' : (result.score >= 80 ? '#3B82F6' : '#F59E0B');
    
    // Prefer allItems, fallback to mistakes if allItems is null (compatibility)
    final items = result.allItems ?? result.mistakes;
    final total = result.total;
    // Calculate correct count based on list content if possible, otherwise use total - mistakes
    final correctCount = result.allItems != null 
        ? result.allItems!.where((i) => i.isCorrect).length 
        : total - result.mistakes.length;
    final mistakeCount = total - correctCount;

    StringBuffer buffer = StringBuffer();
    buffer.write('''
      <div style="font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #334155; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);">
        
        <!-- Header -->
        <div style="background-color: $color; padding: 30px 20px; text-align: center; color: white;">
          <h1 style="margin: 0; font-size: 48px; font-weight: 800; letter-spacing: -1px;">${result.score}<span style="font-size: 24px;">分</span></h1>
          <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">${session.mode.label} · ${_formatDate(DateTime.now())}</p>
        </div>
        
        <!-- Stats Grid -->
        <div style="padding: 24px; border-bottom: 1px solid #E2E8F0;">
          <div style="display: flex; justify-content: space-between; text-align: center;">
            <div style="flex: 1;">
              <div style="font-size: 24px; font-weight: bold; color: #0F172A;">$total</div>
              <div style="font-size: 12px; color: #64748B; text-transform: uppercase; letter-spacing: 1px;">总词数</div>
            </div>
            <div style="flex: 1; border-left: 1px solid #F1F5F9; border-right: 1px solid #F1F5F9;">
              <div style="font-size: 24px; font-weight: bold; color: #10B981;">$correctCount</div>
              <div style="font-size: 12px; color: #64748B; text-transform: uppercase; letter-spacing: 1px;">正确</div>
            </div>
            <div style="flex: 1; border-right: 1px solid #F1F5F9;">
              <div style="font-size: 24px; font-weight: bold; color: #EF4444;">$mistakeCount</div>
              <div style="font-size: 12px; color: #64748B; text-transform: uppercase; letter-spacing: 1px;">错误</div>
            </div>
            <div style="flex: 1;">
              <div style="font-size: 24px; font-weight: bold; color: #3B82F6;">${_formatDuration(result.durationSeconds)}</div>
              <div style="font-size: 12px; color: #64748B; text-transform: uppercase; letter-spacing: 1px;">总用时</div>
            </div>
          </div>
        </div>

        <!-- Detail List -->
        <div style="padding: 0 24px 24px 24px;">
          <h3 style="color: #0F172A; margin: 24px 0 16px 0; font-size: 18px; border-left: 4px solid $color; padding-left: 12px;">学习详情</h3>
          
          <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
            <thead>
              <tr style="background-color: #F8FAFC; color: #64748B; text-align: left;">
                <th style="padding: 12px 8px; font-weight: 600; border-radius: 6px 0 0 6px;">单词</th>
                <th style="padding: 12px 8px; font-weight: 600;">你的回答</th>
                <th style="padding: 12px 8px; font-weight: 600; border-radius: 0 6px 6px 0;">正确答案</th>
              </tr>
            </thead>
            <tbody>
    ''');

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      final rowBg = item.isCorrect ? '#ffffff' : '#FEF2F2';
      final statusColor = item.isCorrect ? '#10B981' : '#EF4444';
      final statusIcon = item.isCorrect ? '✓' : '✕';
      
      buffer.write('''
              <tr style="border-bottom: ${isLast ? 'none' : '1px solid #F1F5F9'}; background-color: $rowBg;">
                <td style="padding: 12px 8px; vertical-align: middle;">
                  <div style="font-weight: bold; color: #0F172A;">${item.word}</div>
                </td>
                <td style="padding: 12px 8px; vertical-align: middle;">
                  <span style="color: ${item.isCorrect ? '#334155' : '#EF4444'}; ${item.isCorrect ? '' : 'text-decoration: line-through; opacity: 0.8;'}">
                    ${item.studentInput?.isNotEmpty == true ? item.studentInput : '(未填写)'}
                  </span>
                </td>
                <td style="padding: 12px 8px; vertical-align: middle;">
                  <div style="color: #10B981; font-weight: 500;">
                    ${item.isCorrect ? '<span style="color:#CBD5E1">--</span>' : (item.correctAnswer ?? item.word)}
                  </div>
                </td>
              </tr>
      ''');
    }

    buffer.write('''
            </tbody>
          </table>
          
          <div style="margin-top: 30px; text-align: center; padding-top: 20px; border-top: 1px dashed #CBD5E1;">
            <p style="margin: 0; font-size: 12px; color: #94A3B8;">
              本邮件由 <strong>单词助手 App</strong> 自动生成<br>
              <a href="#" style="color: #CBD5E1; text-decoration: none;">加油，坚持就是胜利！</a>
            </p>
          </div>
        </div>
      </div>
    ''');
    
    return buffer.toString();
  }
}
