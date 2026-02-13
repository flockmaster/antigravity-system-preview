import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import 'email_settings_view_model.dart';

class EmailSettingsView extends StackedView<EmailSettingsViewModel> {
  const EmailSettingsView({super.key});

  @override
  void onViewModelReady(EmailSettingsViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    EmailSettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('学习报告邮件通知', style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.slate900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.save, color: AppColors.violet600),
            onPressed: viewModel.isBusy ? null : viewModel.saveSettings,
          )
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Enable Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate100),
                      ),
                      child: SwitchListTile(
                        title: const Text('启用邮件通知', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('每次学习/听写结束后自动发送报告'),
                        value: viewModel.isEnabled,
                        onChanged: viewModel.toggleEnabled,
                        activeColor: AppColors.violet500,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text('SMTP 服务器配置', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildSmtpCard(viewModel),

                    const SizedBox(height: 24),

                    const Text('接收邮箱列表', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildRecipientsCard(viewModel),

                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(LucideIcons.send, size: 18),
                        label: const Text('发送测试邮件'),
                        onPressed: viewModel.testEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.slate900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSmtpCard(EmailSettingsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: viewModel.serverController,
                  decoration: const InputDecoration(
                    labelText: 'SMTP 服务器',
                    hintText: '例如 smtp.qq.com',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => v!.isEmpty ? '必填' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: viewModel.portController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: '端口',
                    hintText: '465',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => v!.isEmpty ? '必填' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: viewModel.usernameController,
            decoration: const InputDecoration(
              labelText: '发件人邮箱',
              hintText: '完整邮箱地址',
              border: OutlineInputBorder(),
              isDense: true,
              prefixIcon: Icon(LucideIcons.mail, size: 18),
            ),
            validator: (v) => v!.contains('@') ? null : '请输入有效邮箱',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: viewModel.passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '邮箱密码 / 授权码',
              helperText: '建议使用应用专用密码或授权码',
              border: OutlineInputBorder(),
              isDense: true,
              prefixIcon: Icon(LucideIcons.lock, size: 18),
            ),
            validator: (v) => v!.isEmpty ? '必填' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientsCard(EmailSettingsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: viewModel.recipientController,
                  decoration: const InputDecoration(
                    labelText: '添加接收邮箱',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onSubmitted: (_) => viewModel.addRecipient(),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: viewModel.addRecipient,
                icon: const Icon(LucideIcons.plus),
                style: IconButton.styleFrom(backgroundColor: AppColors.violet500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (viewModel.recipients.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('暂无接收人', style: TextStyle(color: AppColors.slate400)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.recipients.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final email = viewModel.recipients[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.user, size: 20, color: AppColors.slate500),
                  title: Text(email),
                  trailing: IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.red500),
                    onPressed: () => viewModel.removeRecipient(email),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  EmailSettingsViewModel viewModelBuilder(BuildContext context) => EmailSettingsViewModel();
}
