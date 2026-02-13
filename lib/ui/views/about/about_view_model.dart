import 'dart:convert';
import 'dart:io';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../../app/app.locator.dart';
import '../../../core/services/database_service.dart';

class AboutViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _databaseService = locator<DatabaseService>();

  void navigateBack() {
    _navigationService.back();
  }

  void showComingSoon(String feature) {
    _dialogService.showDialog(
      title: '敬请期待',
      description: '$feature 暂未开放',
    );
  }

  Future<void> exportData() async {
    setBusy(true);
    try {
      // 1. Get raw data map from service
      final data = await _databaseService.exportAllData();
      
      // 2. Convert to JSON String
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // 3. Create Temp File
      final tempDir = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'dictation_backup_$dateStr.json';
      final file = File('${tempDir.path}/$fileName');
      
      await file.writeAsString(jsonString);

      // 4. Share File
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '单词助手备份数据 ($dateStr)',
        text: '这是我的单词学习备份数据，请妥善保存。',
      );
      
    } catch (e) {
      _dialogService.showDialog(
        title: '导出失败',
        description: '发生错误: $e',
      );
    } finally {
      setBusy(false);
    }
  }
}
