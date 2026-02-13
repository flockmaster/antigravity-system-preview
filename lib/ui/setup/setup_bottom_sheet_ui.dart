import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../core/enums/bottom_sheet_type.dart';
import '../bottom_sheets/list_bottom_sheet/list_bottom_sheet.dart';

void setupBottomSheetUi() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = {
    BottomSheetType.list: (context, sheetRequest, completer) =>
        ListBottomSheet(request: sheetRequest, completer: completer),
  };

  bottomSheetService.setCustomSheetBuilders(builders);
}
