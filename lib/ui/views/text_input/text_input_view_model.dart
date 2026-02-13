import 'package:flutter/material.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/base/baic_base_view_model.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/dictation_service.dart';

class TextInputViewModel extends BaicBaseViewModel {
  final _aiService = locator<AiService>();
  final _dictationService = locator<DictationService>();

  final TextEditingController textController = TextEditingController(); 
  final FocusNode focusNode = FocusNode();

  bool _isFocused = false;
  bool get isFocused => _isFocused;

  TextInputViewModel() {
    focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    _isFocused = focusNode.hasFocus;
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.removeListener(_onFocusChanged);
    focusNode.dispose();
    super.dispose();
  }
  // Actually, standard stacked is View handles controller or VM holds it. Let's let View pass string to VM method for simplicity.

  bool _isExtracting = false;
  bool get isExtracting => _isExtracting;

  void onCancel() {
    navigationService.back();
  }

  Future<void> extractWords(String text) async {
    if (text.trim().isEmpty) return;

    setBusy(true);
    _isExtracting = true;
    notifyListeners();

    // Call AI Service
    final words = await _aiService.extractWordsFromText(text);

    _isExtracting = false;
    setBusy(false);
    
    if (words.isNotEmpty) {
      _dictationService.setWords(words);
      navigationService.navigateToWordListView(); 
    } else {
      // Show error (snackbar or dialog) - simplified for now
    }
  }
}
