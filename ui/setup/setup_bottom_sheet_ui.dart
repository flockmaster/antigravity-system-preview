import 'package:word_assistant/app/app.locator.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

void setupBottomSheetUI() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = <dynamic, Widget Function(BuildContext, SheetRequest, void Function(SheetResponse))>{
    // TODO: 在这里添加自定义底部弹窗构建器
    // BottomSheetType.basic: (context, sheetRequest, completer) => BasicSheet(request: sheetRequest, completer: completer),
  };

  bottomSheetService.setCustomSheetBuilders(builders);
}
