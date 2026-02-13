import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/base/baic_base_view_model.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/dictation_service.dart';
import '../../../core/models/dictation_session.dart';
import '../../../core/models/word.dart';

enum SortOption {
  recentlyAdded,
  recentlyReviewed,
  longestUnreviewed,
  mostMistakes,
  leastMastered,
  alphabetical
}

class LibraryViewModel extends BaicBaseViewModel {
  final _dbService = locator<DatabaseService>();
  final _ttsService = locator<TtsService>();
  final _dictationService = locator<DictationService>();

  // 数据字段
  List<Word> _allWords = [];
  List<Word> _filteredWords = [];
  List<Word> get words => _filteredWords;

  // 仪表盘统计数据
  int get totalWords => _allWords.length;
  
  // 熟练度计数
  int get graduatedCount => _allWords.where((w) => w.isGraduated).length;
  int get learningCount => _allWords.length - graduatedCount;

  // 每周增长趋势 (最近 7 天)
  List<int> _weeklyTrend = List.filled(7, 0);
  List<int> get weeklyTrend => _weeklyTrend;

  // 排序与筛选
  String? _selectedLetter;
  String? get selectedLetter => _selectedLetter;

  SortOption _currentSort = SortOption.recentlyAdded;
  SortOption get currentSort => _currentSort;

  // 选择模式
  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;

  final Set<String> _selectedIds = {};
  int get selectedCount => _selectedIds.length;
  bool isSelected(String id) => _selectedIds.contains(id);

  // 用于 UI 的字母表列表
  final List<String> alphabet = List.generate(26, (index) => String.fromCharCode(65 + index));

  bool get isClean => _allWords.isEmpty;

  Future<void> init() async {
    setBusy(true);
    await _fetchData();
    setBusy(false);
  }

  Future<void> _fetchData() async {
    // 1. 获取所有单词
    _allWords = await _dbService.getAllWords();
    
    // 2. 计算每周趋势 (真实数据)
    _calculateWeeklyTrend();

    _applyFilter();
  }

  void _calculateWeeklyTrend() {
    _weeklyTrend = List.filled(7, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (var word in _allWords) {
      if (word.firstMasteredAt != null) {
        final date = word.firstMasteredAt!;
        final masteredDay = DateTime(date.year, date.month, date.day);
        final diff = today.difference(masteredDay).inDays;
        
        // 0 表示今天，6 表示 7 天前
        if (diff >= 0 && diff < 7) {
          // 映射到索引：6 是今天，0 是 7 天前（图表从左到右）
          int index = 6 - diff;
          _weeklyTrend[index]++; 
        }
      }
    }
  }

  void setLetterFilter(String? letter) {
    if (_selectedLetter == letter) {
      _selectedLetter = null;
    } else {
      _selectedLetter = letter;
    }
    _applyFilter();
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _currentSort = option;
    _applyFilter();
    notifyListeners();
  }

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedIds.clear();
    }
    notifyListeners();
  }

  void toggleWordSelection(Word word) {
    if (_selectedIds.contains(word.id)) {
      _selectedIds.remove(word.id);
    } else {
      _selectedIds.add(word.id);
    }
    notifyListeners();
  }

  void selectAll() {
    if (_selectedIds.length == _filteredWords.length) {
      _selectedIds.clear();
    } else {
      _selectedIds.addAll(_filteredWords.map((w) => w.id));
    }
    notifyListeners();
  }

  /// 使用选中的单词开始阶梯学习
  void startSelectedReviewLearning() {
    if (_selectedIds.isEmpty) return;
    
    final selectedWords = _allWords.where((w) => _selectedIds.contains(w.id)).toList();
    // 跳转到循序渐进的学习会话(阶梯模式)
    navigationService.navigateToLearningSessionView(
      words: selectedWords, 
      source: 'library',
    );
    
    // 开始后重置选择
    toggleSelectionMode();
  }

  /// 使用选中的单词开始复习 (听写)
  void startSelectedReviewDictation() {
    if (_selectedIds.isEmpty) return;
    
    final selectedWords = _allWords.where((w) => _selectedIds.contains(w.id)).toList();
    // 使用特定的“自定义选择”标签开始混合会话，以便记录历史
    _dictationService.startMixedSession(
      selectedWords, 
      specificMode: DictationMode.customSelection
    );
    navigationService.navigateToDictationView();
    
    // 开始后重置选择
    toggleSelectionMode();
  }



  void _applyFilter() {
    List<Word> temp = List.from(_allWords);
    
    // 1. 字母筛选
    if (_selectedLetter != null) {
      temp = temp.where((w) => w.word.toUpperCase().startsWith(_selectedLetter!)).toList();
    }
    
    // 2. 排序逻辑
    switch (_currentSort) {
      case SortOption.recentlyAdded:
        // 假定默认顺序
        break;
        
      case SortOption.recentlyReviewed:
        temp.sort((a, b) {
           final aTime = a.lastReviewedAt?.millisecondsSinceEpoch ?? 0;
           final bTime = b.lastReviewedAt?.millisecondsSinceEpoch ?? 0;
           return bTime.compareTo(aTime); // 降序
        });
        break;
        
      case SortOption.longestUnreviewed:
        temp.sort((a, b) {
           final aTime = a.lastReviewedAt?.millisecondsSinceEpoch ?? 0;
           final bTime = b.lastReviewedAt?.millisecondsSinceEpoch ?? 0;
           return aTime.compareTo(bTime);
        });
        break;
        
      case SortOption.mostMistakes:
        temp.sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
        break;
      
      case SortOption.leastMastered:
        // 按毕业状态排序（未毕业优先），然后按推荐分数排序（分数越高 = 越需要复习 = 越靠前）
        // 或者是特定逻辑？
        // 比如：未毕业优先，然后是已毕业。
        temp.sort((a, b) {
          if (a.isGraduated == b.isGraduated) {
            // 状态相同，检查分数
             return b.recommendationScore.compareTo(a.recommendationScore);
          }
          return a.isGraduated ? 1 : -1; // 假 (0) < 真 (1)。因此未毕业的排在前面。
        });
        break;

      case SortOption.alphabetical:
        temp.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
        break;
    }
    
    _filteredWords = temp;
  }

  /// 编辑单词回调
  Future<void> onEditWord(Word word, {
    required String newSpelling,
    required String newMeaning,
    String? newPhonetic,
    String? newSentence,
  }) async {
    final updated = word.copyWith(
      word: newSpelling,
      meaningForDictation: newMeaning,
      phonetic: newPhonetic ?? word.phonetic,
      sentence: newSentence ?? word.sentence,
    );
    await _dbService.updateWord(updated);
    await _fetchData(); // 刷新列表
    notifyListeners();
  }

  /// 删除单词回调
  Future<void> onDeleteWord(Word word) async {
    await _dbService.deleteWord(word.id);
    await _fetchData(); // 刷新列表
    notifyListeners();
  }

  /// 播放单词发音
  void speakWord(Word word) {
    _ttsService.speakEnglish(word.word);
  }
}
