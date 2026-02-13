import 'package:word_assistant/app/app.locator.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

void setupDialogUI() {
  final dialogService = locator<DialogService>();

  final builders = <dynamic, Widget Function(BuildContext, DialogRequest, void Function(DialogResponse))>{
    // TODO: 在这里添加自定义对话框构建器
    // DialogType.basic: (context, sheetRequest, completer) => BasicDialog(request: sheetRequest, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
