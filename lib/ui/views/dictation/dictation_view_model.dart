import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/models/word.dart';
import '../../../core/models/dictation_session.dart';
import '../../../core/services/dictation_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/streak_rewards.dart';

/// 听写测试视图模型
class DictationViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dictationService = locator<DictationService>();
  final _ttsService = locator<TtsService>();
  final _dbService = locator<DatabaseService>();
  final _aiService = locator<AiService>();
  final _userService = locator<UserService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_dictationService];

  // Legacy/Fallback Mode Getter
  DictationMode get mode => _dictationService.currentMode;

  // -- Dynamic Properties from Service --
  // We now support mixed queues. If the service has a queue, we use it. 
  // If not (legacy check), we fallback to currentWords.
  // Actually, Service was updated to always have a queue (even explicit setWords builds one? No, explicit setMode does).
  // Current legacy flow: setWords -> setMode (builds uniform queue) -> init. 
  // New flow: startMixedSession (builds mixed queue) -> init.
  // So 'queue' is the source of truth.
  
  List<DictationItem> get queue => _dictationService.queue;
  
  // Fallback for safety if queue is empty but currentWords has data (shouldn't happen in proper flow)
  bool get hasQueue => queue.isNotEmpty;
  
  String get inputMethod => _dictationService.inputMethod;
  bool get isDigital => inputMethod == 'digital';

  // Digital Input State
  // Config: Key is Item ID (unique), Value is User Input
  final Map<String, String> _answers = {};
  
  bool _isShake = false;
  bool get isShake => _isShake;

  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();
  String _currentInput = '';

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  DateTime? _startTime;

  // -- Current Item Helpers --
  DictationItem get currentItem => queue[_currentIndex];
  Word get currentWord => currentItem.word;
  DictationMode get currentItemMode => currentItem.mode;

  bool get isLastItem => _currentIndex == queue.length - 1;

  // -- Init --
  void init() async {
    // 记录会话开始时间
    _startTime = DateTime.now();
    
    AppLogger.d('DictationViewModel Init: Queue Length ${queue.length}');
    if (queue.isEmpty) {
      AppLogger.w('Warning: Queue is empty!');
    } else {
      // 优化：等待页面转场动画完成 (约 300-500ms) 再开始播报
      // 避免动画卡顿和声音突兀
      await Future.delayed(const Duration(milliseconds: 500));
      
      _playCurrentItem();
      
      if (isDigital) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!inputFocusNode.hasPrimaryFocus) inputFocusNode.requestFocus();
        });
      }
    }
  }

  void updateInput(String value) {
    _currentInput = value;
    notifyListeners();
  }

  /// Play audio based on the specific mode of the CURRENT item
  /// 使用分步播放方式,提高语音质量并降低API调用次数
  Future<void> _playCurrentItem() async {
    _isSpeaking = true;
    notifyListeners();
    
    try {
      // 根据模式分步播放(提示词可缓存复用,节省API调用和存储空间)
      switch (currentItemMode) {
        case DictationMode.modeA: // 标准听写: 听英语 → 写英语
          await _ttsService.speakChinese('请拼写');
          await Future.delayed(const Duration(milliseconds: 500));
          await _ttsService.speakEnglish(currentWord.word);
          break;
          
        case DictationMode.modeB: // 中译英: 听中文 → 写英语
          await _ttsService.speakChinese('请翻译');
          await Future.delayed(const Duration(milliseconds: 500));
          await _ttsService.speakChinese(currentWord.meaningForDictation);
          break;
          
        case DictationMode.modeC: // 听音释义: 听英语 → 写中文
          await _ttsService.speakEnglish(currentWord.word);
          await Future.delayed(const Duration(milliseconds: 500));
          await _ttsService.speakChinese('请说出中文意思');
          break;
          
        default: // 默认使用标准听写模式
          await _ttsService.speakChinese('请拼写');
          await Future.delayed(const Duration(milliseconds: 500));
          await _ttsService.speakEnglish(currentWord.word);
          break;
      }
    } catch (e) {
      AppLogger.e('Error playing audio sequence', error: e);
    }
    
    _isSpeaking = false;
    notifyListeners();
  }


  /// Next Item
  void next() async {
    if (isDigital) {
      // Prevent empty submission
      if (_currentInput.trim().isEmpty) {
        _isShake = true;
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 500), () {
          _isShake = false;
          notifyListeners();
        });
        return;
      }

      // Save answer using Item ID (Composite ID)
      _answers[currentItem.id] = _currentInput;
      inputController.clear();
      _currentInput = '';
    }

    if (isLastItem) {
      _finishSession();
    } else {
        // 给足时间让键盘完全收起 (经验值：200ms - 300ms)
      _currentIndex++;
      notifyListeners();
      
      _playCurrentItem();
       
      // 优化输入体验：
      // 1. 移除键盘收起逻辑：避免界面闪烁
      // 2. 保持 FocusNode 活跃：连续输入更流畅
      if (isDigital) {
         if (!inputFocusNode.hasPrimaryFocus) {
           inputFocusNode.requestFocus();
         }
      }
    }
  }

  Future<void> _finishSession() async {
    if (isDigital) {
      final mistakes = <Mistake>[];
      int correctCount = 0;
      
      _isAnalyzing = true;
      notifyListeners();
      
      // 1. Collect Mode C items for AI Grading
      Map<String, bool> aiResults = {};
      
      // Items where Mode is C
      final modeCItems = queue.where((item) => item.mode == DictationMode.modeC).toList();
      if (modeCItems.isNotEmpty) {
          final itemsToGrade = modeCItems.where((item) {
             final input = _answers[item.id]?.trim() ?? '';
             return input.isNotEmpty;
          }).map((item) => {
            'id': item.id, // Using Item ID for AI map
            'word': item.word.word,
            'standard': item.word.meaningForDictation,
            'user_input': _answers[item.id]?.trim() ?? '',
          }).toList();
          
          if (itemsToGrade.isNotEmpty) {
            // Note: AI Service expects a map, we pass Item ID as 'id' key
             aiResults = await _aiService.gradeMeaningDictation(itemsToGrade);
          }
      }

      // Helper Cleaner
      String clean(String s) {
          var out = s.toLowerCase();
          out = out.replaceAll(RegExp(r'（[^）]*）|\([^)]*\)'), ''); 
          out = out.replaceAll(RegExp(r'[.,;:"!?。，；：“”！？（）()[\]{}]'), '');
          out = out.replaceAll(RegExp(r'^[a-z]+\.?'), ''); 
          return out.trim();
      }
      
      // 2. Grade All Items
      final allItems = <Mistake>[]; // Store all items for review

      for (var item in queue) {
        final userAnswer = _answers[item.id]?.trim() ?? '';
        bool isCorrect = false;
        
        if (item.mode == DictationMode.modeC) {
          // AI Check + Fallback
          if (aiResults.containsKey(item.id)) {
            isCorrect = aiResults[item.id]!;
          } else if (userAnswer.isNotEmpty) {
             // Fallback Logic
             final separators = RegExp(r'[,;，；\s]+');
             final correctSegments = item.word.meaningForDictation.split(separators);
             final cleanUser = clean(userAnswer);

             if (cleanUser.isNotEmpty) {
                for (var segment in correctSegments) {
                  var cleanSegment = clean(segment);
                  if (cleanSegment.isEmpty) continue;
                  if (cleanSegment.contains(cleanUser) || cleanUser.contains(cleanSegment)) {
                    isCorrect = true;
                    break;
                  }
                }
             }
          }
        } else {
          // Mode A & B check English string
          isCorrect = userAnswer.toLowerCase() == item.word.word.trim().toLowerCase();
        }
        
        String standardAnswer = '';
        if (item.mode == DictationMode.modeC) {
           standardAnswer = item.word.meaningForDictation;
        } else {
           standardAnswer = item.word.word;
        }

        final mistakeObj = Mistake(
          word: item.word.word, // We record base word
          studentInput: userAnswer,
          isCorrect: isCorrect,
          mode: item.mode, // Record the mode
          wordId: item.word.id,
          correctAnswer: standardAnswer,
        );

        allItems.add(mistakeObj);

        if (isCorrect) {
          correctCount++;
          // _updateItemMastery(item);
        } else {
          mistakes.add(mistakeObj);
        }
      }
      
      final stats = <String, int>{
        'total_A': queue.where((i) => i.mode == DictationMode.modeA).length,
        'total_B': queue.where((i) => i.mode == DictationMode.modeB).length,
        'total_C': queue.where((i) => i.mode == DictationMode.modeC).length,
      };

      final scanResult = SessionResult(
         sessionId: DateTime.now().toIso8601String(),
         score: (correctCount / queue.length * 100).round(),
         total: queue.length,
         mistakes: mistakes,
         allItems: allItems,
         stats: stats,
        );
      
      try {
        // Use the specific mode from the service (e.g. MistakeCrusher) if it was set
        // Otherwise, auto-detect Mixed only if the service mode is Generic Mixed or A (fallback)
        var finalMode = _dictationService.currentMode;
        
        // If currentMode is generic A but we detected mixed activity, upgrade to generic Mixed
        // But if it's already specific (e.g. MistakeCrusher), keep it!
        bool isServiceModeSpecific = finalMode == DictationMode.mistakeCrusher || 
                                     finalMode == DictationMode.smartReview || 
                                     finalMode == DictationMode.customSelection;
                                     
        if (!isServiceModeSpecific) {
          int activeModes = 0;
          if ((stats['total_A'] ?? 0) > 0) activeModes++;
          if ((stats['total_B'] ?? 0) > 0) activeModes++;
          if ((stats['total_C'] ?? 0) > 0) activeModes++;
          if (activeModes > 1) {
             finalMode = DictationMode.modeMixed;
          }
        }

        final uniqueWords = queue.map((i) => i.word).toSet().toList();
        
        final session = DictationSession(
          sessionId: scanResult.sessionId,
          mode: finalMode, 
          date: scanResult.sessionId,
          words: uniqueWords,
        );
        
        // 计算完成时长(秒)
        int? durationSeconds;
        if (_startTime != null) {
          final endTime = DateTime.now();
          durationSeconds = endTime.difference(_startTime!).inSeconds;
        }
        
        await _dbService.saveSession(session, scanResult, durationSeconds: durationSeconds);
        
        // --- 积分奖励逻辑 ---
        // 基础分：每个正确单词 1 积分
        int pointsEarned = correctCount;
        // 满分加分：如果是满分且单词数超过 3 个，额外奖励 5 积分
        if (scanResult.score == 100 && queue.length >= 3) {
          pointsEarned += 5;
        }
        if (pointsEarned > 0) {
          await _userService.addPoints(pointsEarned);
        }
        await StreakRewards.maybeGrantGoldBonusForDate(
          dbService: _dbService,
          userService: _userService,
          date: DateTime.now(),
        );
        // ------------------
      } catch (e) {
        AppLogger.e('Error saving session', error: e);
      }
      
      _isAnalyzing = false;
      notifyListeners();
      
      _dictationService.setResult(scanResult);
      _navigationService.navigateToResultView();
    } else {
       _navigationService.navigateToScanSheetView();
    }
  }



  @override
  void dispose() {
    inputController.dispose();
    inputFocusNode.dispose();
    super.dispose();
  }

  String getModeLabel() {
    // If mixed, show item mode
    return currentItemMode.label;
  }
}
