import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/models/word.dart';
import '../../../core/services/dictation_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/app_logger.dart';

/// 单词列表视图模型
/// 
/// 支持两种模式：
/// 1. 确认模式：显示刚从图片中提取出的单词。
/// 2. 词库模式：显示本地数据库中存储的所有单词。
class WordListViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _dictationService = locator<DictationService>();
  final _ttsService = locator<TtsService>();
  final _dbService = locator<DatabaseService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_dictationService, _dbService];

  bool _isLibraryMode = false;
  bool _isMistakeMode = false;
  bool _isSmartReviewMode = false;

  bool get isLibraryMode => _isLibraryMode;
  bool get isMistakeMode => _isMistakeMode;
  bool get isSmartReviewMode => _isSmartReviewMode;

  // -- Data Source --
  List<Word> _rawWords = []; // Loaded from DB

  // -- Categorized Lists --
  List<Word> _atRiskWords = [];
  List<Word> _inProgressWords = [];

  // -- Tab State --
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  void setTabIndex(int index) {
    _tabIndex = index;
    _selectedIds.clear(); 
    // If in At Risk tab, default select all for convenience
    if (index == 0 && _isSmartReviewMode) {
      _selectedIds.addAll(words.map((e) => e.id));
    }
    notifyListeners();
  }
  
  // -- Selection State --
  final Set<String> _selectedIds = {};
  
  // -- Getters --
  List<Word> get words {
    if (_isMistakeMode) return _rawWords; // Mistake mode is flat list
    if (!_isLibraryMode) return _dictationService.currentWords; // Confirm mode

    // Smart Library Mode (Tabbed)
    switch (_tabIndex) {
      case 0: return _atRiskWords;
      case 1: return _inProgressWords;
      case 2: return _rawWords; // All
      default: return _rawWords;
    }
  }
  
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;

  bool isSelected(String id) => _selectedIds.contains(id);

  /// Init
  Future<void> init({bool isLibrary = false, bool isMistakes = false, bool isSmartReview = false}) async {
    _isLibraryMode = isLibrary;
    _isMistakeMode = isMistakes;
    _isSmartReviewMode = isSmartReview;

    setBusy(true);
    await _fetchData();
    setBusy(false);
    
    // Default select all logic
    if (_isMistakeMode || !_isLibraryMode || (_isLibraryMode && _tabIndex == 0)) {
       _selectedIds.addAll(words.map((e) => e.id));
    }
    notifyListeners();
  }

  // Override to handle DB updates
  void onChange(ListenableServiceMixin? service) {
    if (service == _dbService && !_isLibraryMode) {
       // Only refresh if we are in library mode (connected to DB)
       // Actually, mistake mode is also DB based.
       // Import mode is not DB based (held in memory service), so don't refresh from DB.
    }
    if ((_isLibraryMode || _isMistakeMode) && service == _dbService) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (_isMistakeMode) {
      _rawWords = await _dbService.getMistakenWords();
    } else if (_isLibraryMode) {
      _rawWords = await _dbService.getAllWords();
      _categorizeLibraryWords();
      
      if (_isSmartReviewMode) {
        _tabIndex = 0;
      } else {
        // If we are already on a tab, stay there? or reset?
        // Let's keep current tab if valid, else default to 2
        if (_tabIndex > 2) _tabIndex = 2;
        // On first load implies init() ran, which sets tab. 
        // This runs on updates too.
      }
    }
    notifyListeners();
  }

  void _categorizeLibraryWords() {
    _atRiskWords = _rawWords.where((w) => w.needsReview).toList();
    // Sort AtRisk by Recommendation Score (Higher score = Higher priority/risk?)
    // OR: Sort by Last Reviewed (Oldest first).
    // Word model says: "Score higher = proper priority".
    _atRiskWords.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));

    _inProgressWords = _rawWords.where((w) => !w.isGraduated).toList();
  }

  /// Toggle selection
  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Speak word
  void speakWord(Word word) {
    _ttsService.speakEnglish(word.word);
  }

  /// Retake / Back
  void onRetake() {
    _navigationService.back();
  }

  /// 仅导入词库（不开始学习）
  Future<void> onImportOnly() async {
    if (!hasSelection || isBusy) return;

    setBusy(true);
    try {
      final selectedWords = words.where((w) => _selectedIds.contains(w.id)).toList();
      
      if (_isLibraryMode || _isMistakeMode) {
        // 词库模式/错题本模式：复习选中 (Mode Selection)
        _dictationService.setWords(selectedWords);
        _navigationService.navigateToModeSelectionView();
      } else {
        // 导入模式：仅保存
        await _dbService.saveWords(selectedWords);
        
        await _dialogService.showDialog(
          title: '导入成功',
          description: '已将 ${selectedWords.length} 个单词导入词库。',
        );
        
        _navigationService.clearStackAndShow(Routes.mainView);
      }
    } catch (e) {
      AppLogger.e('导入词库失败', error: e);
      await _dialogService.showDialog(title: '错误', description: '$e');
    } finally {
      setBusy(false);
    }
  }

  /// 导入词库并开始学习
  Future<void> onImportAndLearn() async {
    if (!hasSelection || isBusy) return;

    setBusy(true);
    try {
      final selectedWords = words.where((w) => _selectedIds.contains(w.id)).toList();
      
      if (_isLibraryMode || _isMistakeMode) {
        // 词库模式：直接进入渐进式学习
        _navigationService.navigateToLearningSessionView(
          words: selectedWords,
          source: 'word_list',
        );
      } else {
        // 导入模式：保存 -> 学习
        await _dbService.saveWords(selectedWords);
        _navigationService.navigateToLearningSessionView(
          words: selectedWords,
          source: 'word_list',
        );
      }
    } catch (e) {
      AppLogger.e('学习启动失败', error: e);
      await _dialogService.showDialog(title: '错误', description: '$e');
    } finally {
      setBusy(false);
    }
  }
}
