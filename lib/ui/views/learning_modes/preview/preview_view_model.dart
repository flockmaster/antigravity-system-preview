import 'dart:ui';
// import 'package:record/record.dart';
// import 'package:audioplayers/audioplayers.dart';
import '../../../../core/services/speech_service.dart';

import '../../../../app/app.locator.dart';
import '../../../../core/base/baic_base_view_model.dart';
import '../../../../core/models/word.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/utils/app_logger.dart';

class PreviewViewModel extends BaicBaseViewModel {
  final _ttsService = locator<TtsService>();
  final _speechService = locator<SpeechService>();
  // final _audioRecorder = AudioRecorder(); // Removed for speech verification focus
  // final _audioPlayer = AudioPlayer();     // Removed for speech verification focus

  final Word word;
  final VoidCallback onNext;

  PreviewViewModel({
    required this.word,
    required this.onNext,
  });

  bool _isFlipped = false;
  bool get isFlipped => _isFlipped;

  bool _isListening = false;
  bool get isListening => _isListening;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  bool _isMatched = false;
  bool get isMatched => _isMatched;

  // Track attempts to allow skip
  int _attempts = 0;
  bool get canSkip => _attempts >= 3;

  void init() {
    speakWord();
  }

  void speakWord() {
    _ttsService.speakEnglish(word.word);
  }

  void flipCard() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  // --- Real Recording Logic ---

  // --- Speech Verification Logic ---

  Future<void> startListening() async {
    _attempts++;
    _isListening = true;
    _recognizedText = '';
    _isMatched = false;
    notifyListeners();

    await _speechService.startListening(
      onResult: (text) {
        _recognizedText = text;
        _checkMatch(text);
        notifyListeners();
      },
    );
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  void _checkMatch(String text) {
    // 判断是否匹配（忽略大小写和空格）
    // 例如: "ARM CHAIR" vs "armchair" → "armchair" vs "armchair" → true
    final normalizedRecognized = text.toLowerCase().replaceAll(' ', '');
    final normalizedTarget = word.word.toLowerCase().replaceAll(' ', '');
    
    if (normalizedRecognized.contains(normalizedTarget)) {
      _isMatched = true;
      _speechService.stopListening();
      _isListening = false;
      // Play success sound? 
      // Ideally trigger some positive feedback
    }
  }

  bool _isRegenerating = false;
  bool get isRegenerating => _isRegenerating;

  final _aiService = locator<AiService>();
  final _dbService = locator<DatabaseService>();

  Future<void> regenerateMnemonic() async {
    _isRegenerating = true;
    notifyListeners();

    try {
      final newMnemonic = await _aiService.generateMnemonic(word.word, word.meaningForDictation);
      if (newMnemonic.isNotEmpty) {
        // Update local word (copy)
        // NOTE: we need a way to update the parent session's word or just this view's word.
        // For persistent update, we save to DB.
        
        final updatedWord = word.copyWith(mnemonic: newMnemonic);
        await _dbService.updateWord(updatedWord);
        
        // Update current view state? 
        // Since 'word' is final, we might need a local display variable or recreate ViewModel?
        // Actually, PreviewView gets 'word' passed in.
        // Stacked ViewModels usually hold state. We should make 'word' mutable or have a 'displayMnemonic' field.
      }
    } catch (e) {
       AppLogger.e('Regenerate Error', error: e);
    } finally {
      _isRegenerating = false;
      notifyListeners();
    }
  }
  
  // We need to override the word getter or add a display field since we can't update final 'word'.
  // Let's rely on the View rebuilding with new data if we pass it, but here we are inside VM.
  // Better: Add a 'currentMnemonic' field.
  
  String? _overriddenMnemonic;
  String get displayMnemonic => _overriddenMnemonic ?? word.mnemonic;

  Future<void> regenerateMnemonicAction() async {
      _isRegenerating = true;
      notifyListeners();

      final newMnemonic = await _aiService.generateMnemonic(word.word, word.meaningForDictation);
      if (newMnemonic.isNotEmpty) {
          _overriddenMnemonic = newMnemonic;
          // Persist
          await _dbService.updateWord(word.copyWith(mnemonic: newMnemonic));
      }
      
      _isRegenerating = false;
      notifyListeners();
  }

  // Legacy recording logic removed

  Future<void> playComparison() async {
    // Simplified comparison: Just TTS
    await _ttsService.speakEnglish(word.word);
  }

  void next() {
    // _audioRecorder.dispose();
    // _audioPlayer.dispose();
    onNext();
  }
  
  @override
  void dispose() {
    // _audioRecorder.dispose();
    // _audioPlayer.dispose();
    super.dispose();
  }
}
