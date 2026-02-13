import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../../core/models/sheet_action.dart';
import '../../../../core/theme/app_colors.dart';

class ListBottomSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const ListBottomSheet({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Expect data to be a list of SheetAction
    final List<SheetAction> actions = request.data is List<SheetAction>
        ? request.data as List<SheetAction>
        : [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (request.title != null) ...[
            Text(
              request.title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (request.description != null) ...[
            Text(
              request.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (actions.isNotEmpty)
             ...actions.map((action) => _buildActionOption(action)).toList()
          else
            const Text('暂无选项', style: TextStyle(color: AppColors.textSecondary)),
            
           // If confirm button title is present, show a cancel button
           if (request.secondaryButtonTitle != null)
             Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: GestureDetector(
                  onTap: () => completer(SheetResponse(confirmed: false)),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderPrimary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      request.secondaryButtonTitle ?? '取消',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
             )
        ],
      ),
    );
  }

  Widget _buildActionOption(SheetAction action) {
    return GestureDetector(
      onTap: () {
        completer(SheetResponse(confirmed: true, data: action.data));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                action.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
