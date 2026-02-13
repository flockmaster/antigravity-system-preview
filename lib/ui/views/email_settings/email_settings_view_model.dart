import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/models/email_config.dart';
import '../../../core/services/email_service.dart';
import '../../../core/utils/app_logger.dart';

class EmailSettingsViewModel extends BaseViewModel {
  final _emailService = locator<EmailService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  final formKey = GlobalKey<FormState>();
  final serverController = TextEditingController();
  final portController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final recipientController = TextEditingController();

  List<String> recipients = [];
  bool isEnabled = false;

  void init() async {
    setBusy(true);
    await _emailService.init();
    final config = _emailService.config;
    
    serverController.text = config.smtpServer;
    portController.text = config.smtpPort.toString();
    usernameController.text = config.username;
    passwordController.text = config.password;
    recipients = List.from(config.recipients);
    isEnabled = config.isEnabled;
    
    setBusy(false);
  }

  void toggleEnabled(bool value) {
    isEnabled = value;
    notifyListeners();
  }

  void addRecipient() {
    final email = recipientController.text.trim();
    if (email.isEmpty) return;
    if (!email.contains('@')) {
      _dialogService.showDialog(title: '错误', description: '请输入有效的邮箱地址');
      return;
    }
    if (recipients.contains(email)) {
      _dialogService.showDialog(title: '错误', description: '该邮箱已存在');
      return;
    }
    
    recipients.add(email);
    recipientController.clear();
    notifyListeners();
  }

  void removeRecipient(String email) {
    recipients.remove(email);
    notifyListeners();
  }

  Future<void> saveSettings() async {
    if (!formKey.currentState!.validate()) return;
    if (recipients.isEmpty && isEnabled) {
      await _dialogService.showDialog(title: '提示', description: '开启邮件通知至少需要添加一个接收邮箱');
      return;
    }

    setBusy(true);
    try {
      final newConfig = EmailConfig(
        smtpServer: serverController.text.trim(),
        smtpPort: int.tryParse(portController.text.trim()) ?? 465,
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        recipients: recipients,
        isEnabled: isEnabled,
      );
      
      await _emailService.saveConfig(newConfig);
      await _dialogService.showDialog(title: '成功', description: '设置已保存');
      _navigationService.back();
    } catch (e) {
      AppLogger.e('Save failed', error: e);
      _dialogService.showDialog(title: '错误', description: '保存失败: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> testEmail() async {
    if (recipients.isEmpty) {
      _dialogService.showDialog(title: '提示', description: '请先添加接收邮箱');
      return;
    }
    
    // Temporarily save config to service so test uses current input
    final tempConfig = EmailConfig(
      smtpServer: serverController.text.trim(),
      smtpPort: int.tryParse(portController.text.trim()) ?? 465,
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      recipients: recipients,
      isEnabled: true,
    );
    await _emailService.saveConfig(tempConfig);

    setBusy(true);
    try {
      await _emailService.sendTestEmail(recipients.first);
      await _dialogService.showDialog(title: '成功', description: '测试邮件已发送至 ${recipients.first}');
    } catch (e) {
      AppLogger.e('Test email failed', error: e);
      await _dialogService.showDialog(title: '发送失败', description: '请检查SMTP配置。\n错误信息: $e');
    } finally {
      setBusy(false);
    }
  }
}
