import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/models/word.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/dictation_service.dart';


class MistakeBookViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dbService = locator<DatabaseService>();
  final _ttsService = locator<TtsService>();
  final _dictationService = locator<DictationService>();

  List<Word> _mistakeWords = [];
  List<Word> get mistakeWords => _mistakeWords;

  final Set<String> _selectedIds = {};
  
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  bool get isAllSelected => _mistakeWords.isNotEmpty && _selectedIds.length == _mistakeWords.length;

  bool isSelected(String id) => _selectedIds.contains(id);

  @override
  List<ListenableServiceMixin> get listenableServices => [_dictationService];

  Future<void> init() async {
    setBusy(true);
    _mistakeWords = await _dbService.getMistakenWords();
    
    // Default: Select All (matches Prototype behavior)
    _selectedIds.addAll(_mistakeWords.map((w) => w.id));
    
    setBusy(false);
  }

  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void toggleSelectAll() {
    if (isAllSelected) {
      _selectedIds.clear();
    } else {
      _selectedIds.clear();
      _selectedIds.addAll(_mistakeWords.map((w) => w.id));
    }
    notifyListeners();
  }

  Future<void> speakWord(String text) async {
    await _ttsService.speakEnglish(text);
  }

  Future<void> startPractice() async {
    if (!hasSelection) return;

    // 使用阶梯学习模式(与智能复习一致)
    final selectedWords = _mistakeWords.where((w) => _selectedIds.contains(w.id)).toList();
    
    // 跳转到循序渐进的学习会话(阶梯模式)
    await _navigationService.navigateToLearningSessionView(
      words: selectedWords, 
      source: 'mistake_book',
    );
  }

  void navigateBack() {
    _navigationService.back();
  }
}
