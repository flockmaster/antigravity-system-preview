import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/app_logger.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  
  bool _isAvailable = false;
  bool _isListening = false;
  
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  String _lastRecognizedWords = '';
  String get lastRecognizedWords => _lastRecognizedWords;

  /// Stream of recognized text for real-time UI updates
  final _recognitionController = StreamController<String>.broadcast();
  Stream<String> get recognitionStream => _recognitionController.stream;

  /// Initialize the speech recognition service
  Future<bool> init() async {
    try {
      _isAvailable = await _speechToText.initialize(
        onError: (error) => AppLogger.e('Speech initialization error: $error'),
        onStatus: (status) {
          AppLogger.d('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          } else if (status == 'listening') {
            _isListening = true;
          }
        },
      );
      return _isAvailable;
    } catch (e) {
      AppLogger.e('Failed to initialize speech service', error: e);
      return false;
    }
  }

  /// Start listening for speech
  /// [onResult] is called with interim results if [partialResults] is true
  Future<void> startListening({
    Function(String)? onResult,
    String? localeId,
  }) async {
    if (!_isAvailable) {
      bool initialized = await init();
      if (!initialized) return;
    }

    if (_isListening) return;

    _lastRecognizedWords = '';
    _recognitionController.add('');

    try {
      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastRecognizedWords = result.recognizedWords;
          _recognitionController.add(_lastRecognizedWords);
          
          if (onResult != null) {
            onResult(_lastRecognizedWords);
          }
        },
        localeId: localeId ?? 'en_US', // Default to English US
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
      );
    } catch (e) {
      AppLogger.e('Error starting speech listen', error: e);
    }
  }

  /// Stop listening manually
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  /// Cancel listening (discards results)
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speechToText.cancel();
      _isListening = false;
    }
  }
  /// Check and request permissions
  /// Returns true if permissions are granted (or already granted)
  /// Returns false if permissions are denied/permanently denied and user needs to go to settings
  Future<bool> checkAndRequestPermissions() async {
    // 1. Check current status
    var statusMic = await Permission.microphone.status;
    var statusSpeech = await Permission.speech.status;

    // 2. If already granted, return true
    if (statusMic.isGranted && statusSpeech.isGranted) {
      return true;
    }

    // 3. If permanently denied (Android), fail immediately to show dialog
    if (statusMic.isPermanentlyDenied || statusSpeech.isPermanentlyDenied) {
      return false;
    }

    // 4. Request permissions (Handles standard request and iOS initial state)
    // On iOS, if previously denied, this will return denied immediately.
    // If initial state, this shows system dialog.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.speech,
    ].request();

    // 5. Check final result
    bool micGranted = statuses[Permission.microphone]!.isGranted;
    bool speechGranted = statuses[Permission.speech]!.isGranted;

    return micGranted && speechGranted;
  }

  /// Open system settings
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
