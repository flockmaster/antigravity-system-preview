import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'package:word_assistant/core/services/edge_tts/edge_tts.dart';
import 'tts_settings_view_model.dart';

/// TTS 语音设置页面
/// 
/// 支持：
/// - TTS 引擎选择（Edge TTS / 科大讯飞 / 系统）
/// - 英语口音切换（美式 / 英式）
/// - 英文语音包选择
/// - 中文语音包选择
class TtsSettingsView extends StackedView<TtsSettingsViewModel> {
  const TtsSettingsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    TtsSettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: const Text('TTS 语音设置'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ===== 语音源选择 =====
          _buildSectionTitle('选择语音引擎'),
          const SizedBox(height: 16),
          // Edge TTS - 推荐选项放在最前面
          _buildSourceCard(
            id: 'edge',
            title: '微软 Edge TTS',
            subtitle: '🌟 推荐 · 免费高质量神经网络语音',
            icon: LucideIcons.globe,
            viewModel: viewModel,
            isRecommended: true,
          ),
          const SizedBox(height: 12),
          // 科大讯飞
          _buildSourceCard(
            id: 'xfyun',
            title: '科大讯飞 (超拟人)',
            subtitle: '高保真在线语音，极其自然（收费）',
            icon: LucideIcons.mic,
            viewModel: viewModel,
          ),
          const SizedBox(height: 12),
          // 系统默认
          _buildSourceCard(
            id: 'system',
            title: '系统默认 (Flutter TTS)',
            subtitle: '使用手机本地离线引擎，响应快',
            icon: LucideIcons.smartphone,
            viewModel: viewModel,
          ),
          
          // ===== Edge TTS 详细设置（仅当选择 Edge TTS 时显示）=====
          if (viewModel.currentSource == 'edge') ...[
            const SizedBox(height: 32),
            
            // 英语口音选择
            _buildSectionTitle('英语口音'),
            const SizedBox(height: 16),
            _buildAccentSelector(viewModel),
            
            const SizedBox(height: 24),
            
            // 英文语音包选择
            _buildSectionTitle('英文语音'),
            const SizedBox(height: 12),
            _buildVoiceGrid(
              voices: viewModel.availableEnglishVoices,
              selectedVoice: viewModel.currentEnglishVoice,
              onSelect: (voice) => viewModel.setEnglishVoice(voice.id),
              onPreview: (voice) => viewModel.previewEnglishVoice(voice.id),
            ),
            
            const SizedBox(height: 24),
            
            // 中文语音包选择
            _buildSectionTitle('中文语音'),
            const SizedBox(height: 12),
            _buildVoiceGrid(
              voices: viewModel.availableChineseVoices,
              selectedVoice: viewModel.currentChineseVoice,
              onSelect: (voice) => viewModel.setChineseVoice(voice.id),
              onPreview: (voice) => viewModel.previewChineseVoice(voice.id),
            ),
          ],
          
          // ===== 科大讯飞参数（仅当选择讯飞时显示）=====
          if (viewModel.currentSource == 'xfyun') ...[
            const SizedBox(height: 32),
            _buildSectionTitle('科大讯飞参数'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.slate100),
              ),
              child: Column(
                children: [
                  _buildSettingRow('发音人 (VCN)', 'x6_lingxiaoxuan_pro'),
                  const Divider(height: 24),
                  _buildSettingRow('语速 (Speed)', '50'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: viewModel.testVoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('测试当前语音', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.slate400,
        letterSpacing: 1,
      ),
    );
  }
  
  /// 构建口音选择器（美式/英式切换）
  Widget _buildAccentSelector(TtsSettingsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildAccentOption(
              accent: EnglishAccent.american,
              label: '🇺🇸 美式英语',
              sublabel: 'American',
              isSelected: viewModel.currentAccent == EnglishAccent.american,
              onTap: () => viewModel.setAccent(EnglishAccent.american),
              isLeft: true,
            ),
          ),
          Container(width: 1, height: 60, color: AppColors.slate100),
          Expanded(
            child: _buildAccentOption(
              accent: EnglishAccent.british,
              label: '🇬🇧 英式英语',
              sublabel: 'British',
              isSelected: viewModel.currentAccent == EnglishAccent.british,
              onTap: () => viewModel.setAccent(EnglishAccent.british),
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建单个口音选项
  Widget _buildAccentOption({
    required EnglishAccent accent,
    required String label,
    required String sublabel,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet50 : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 19 : 0),
            bottomLeft: Radius.circular(isLeft ? 19 : 0),
            topRight: Radius.circular(isLeft ? 0 : 19),
            bottomRight: Radius.circular(isLeft ? 0 : 19),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.violet600 : AppColors.slate600,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.checkCircle2, color: AppColors.violet500, size: 16),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.violet400 : AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建语音包网格
  Widget _buildVoiceGrid({
    required List<VoiceInfo> voices,
    required String selectedVoice,
    required Function(VoiceInfo) onSelect,
    required Function(VoiceInfo) onPreview,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: voices.map((voice) {
        final isSelected = voice.id == selectedVoice;
        return _buildVoiceChip(
          voice: voice,
          isSelected: isSelected,
          onTap: () => onSelect(voice),
          onPreview: () => onPreview(voice),
        );
      }).toList(),
    );
  }
  
  /// 构建语音选择卡片
  Widget _buildVoiceChip({
    required VoiceInfo voice,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onPreview,
  }) {
    // 根据性别选择图标
    final genderIcon = voice.isFemale ? LucideIcons.user : LucideIcons.userCircle2;
    final genderColor = voice.isFemale ? AppColors.rose400 : AppColors.blue500;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.violet400 : AppColors.slate200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.violet100.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 性别图标
            Icon(genderIcon, size: 16, color: genderColor),
            const SizedBox(width: 8),
            // 语音名称
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voice.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.violet600 : AppColors.slate700,
                  ),
                ),
                Text(
                  voice.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? AppColors.violet500 : AppColors.slate400,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // 试听按钮
            GestureDetector(
              onTap: onPreview,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.violet100 : AppColors.slate100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.volume2,
                  size: 14,
                  color: isSelected ? AppColors.violet600 : AppColors.slate500,
                ),
              ),
            ),
            // 选中标记
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.violet500),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required TtsSettingsViewModel viewModel,
    bool isAvailable = true,
    bool isRecommended = false,
  }) {
    final isSelected = viewModel.currentSource == id;
    
    // 推荐选项使用绿色主题
    final accentColor = isRecommended ? AppColors.emerald500 : AppColors.violet500;
    final accentLight = isRecommended ? AppColors.emerald50 : AppColors.violet50;
    
    return GestureDetector(
      onTap: isAvailable ? () => viewModel.setSource(id) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.slate100,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: accentColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))
          ] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isSelected ? accentLight : AppColors.slate50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? accentColor : AppColors.slate300, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? AppColors.slate900 : AppColors.slate300,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '免费',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.emerald600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isAvailable ? AppColors.slate400 : AppColors.slate200,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.checkCircle2, color: accentColor, size: 24)
            else if (!isAvailable)
              const Text('即将推出', style: TextStyle(fontSize: 11, color: AppColors.slate300, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate900)),
      ],
    );
  }

  @override
  TtsSettingsViewModel viewModelBuilder(BuildContext context) => TtsSettingsViewModel();
}
