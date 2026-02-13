// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/foundation.dart' as _i25;
import 'package:flutter/material.dart' as _i24;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i27;
import 'package:word_assistant/core/models/word.dart' as _i26;
import 'package:word_assistant/ui/views/about/about_view.dart' as _i23;
import 'package:word_assistant/ui/views/dictation/dictation_view.dart' as _i7;
import 'package:word_assistant/ui/views/email_settings/email_settings_view.dart'
    as _i22;
import 'package:word_assistant/ui/views/home/home_view.dart' as _i3;
import 'package:word_assistant/ui/views/learning_modes/construction/construction_view.dart'
    as _i18;
import 'package:word_assistant/ui/views/learning_modes/learning_session_view.dart'
    as _i20;
import 'package:word_assistant/ui/views/learning_modes/preview/preview_view.dart'
    as _i16;
import 'package:word_assistant/ui/views/learning_modes/recall/recall_view.dart'
    as _i19;
import 'package:word_assistant/ui/views/learning_modes/recognition/recognition_view.dart'
    as _i17;
import 'package:word_assistant/ui/views/library/library_view.dart' as _i12;
import 'package:word_assistant/ui/views/main/main_view.dart' as _i2;
import 'package:word_assistant/ui/views/mistake_book/mistake_book_view.dart'
    as _i13;
import 'package:word_assistant/ui/views/mode_selection/mode_selection_view.dart'
    as _i6;
import 'package:word_assistant/ui/views/personal_center/personal_center_view.dart'
    as _i15;
import 'package:word_assistant/ui/views/result/result_view.dart' as _i9;
import 'package:word_assistant/ui/views/scan_book/scan_book_view.dart' as _i4;
import 'package:word_assistant/ui/views/scan_sheet/scan_sheet_view.dart' as _i8;
import 'package:word_assistant/ui/views/smart_review/smart_review_view.dart'
    as _i11;
import 'package:word_assistant/ui/views/statistics/statistics_view.dart'
    as _i21;
import 'package:word_assistant/ui/views/text_input/text_input_view.dart'
    as _i10;
import 'package:word_assistant/ui/views/tts_settings/tts_settings_view.dart'
    as _i14;
import 'package:word_assistant/ui/views/word_list/word_list_view.dart' as _i5;

class Routes {
  static const mainView = '/';

  static const homeView = '/home-view';

  static const scanBookView = '/scan-book-view';

  static const wordListView = '/word-list-view';

  static const modeSelectionView = '/mode-selection-view';

  static const dictationView = '/dictation-view';

  static const scanSheetView = '/scan-sheet-view';

  static const resultView = '/result-view';

  static const textInputView = '/text-input-view';

  static const smartReviewView = '/smart-review-view';

  static const libraryView = '/library-view';

  static const mistakeBookView = '/mistake-book-view';

  static const ttsSettingsView = '/tts-settings-view';

  static const personalCenterView = '/personal-center-view';

  static const previewView = '/preview-view';

  static const recognitionView = '/recognition-view';

  static const constructionView = '/construction-view';

  static const recallView = '/recall-view';

  static const learningSessionView = '/learning-session-view';

  static const statisticsView = '/statistics-view';

  static const emailSettingsView = '/email-settings-view';

  static const aboutView = '/about-view';

  static const all = <String>{
    mainView,
    homeView,
    scanBookView,
    wordListView,
    modeSelectionView,
    dictationView,
    scanSheetView,
    resultView,
    textInputView,
    smartReviewView,
    libraryView,
    mistakeBookView,
    ttsSettingsView,
    personalCenterView,
    previewView,
    recognitionView,
    constructionView,
    recallView,
    learningSessionView,
    statisticsView,
    emailSettingsView,
    aboutView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.mainView,
      page: _i2.MainView,
    ),
    _i1.RouteDef(
      Routes.homeView,
      page: _i3.HomeView,
    ),
    _i1.RouteDef(
      Routes.scanBookView,
      page: _i4.ScanBookView,
    ),
    _i1.RouteDef(
      Routes.wordListView,
      page: _i5.WordListView,
    ),
    _i1.RouteDef(
      Routes.modeSelectionView,
      page: _i6.ModeSelectionView,
    ),
    _i1.RouteDef(
      Routes.dictationView,
      page: _i7.DictationView,
    ),
    _i1.RouteDef(
      Routes.scanSheetView,
      page: _i8.ScanSheetView,
    ),
    _i1.RouteDef(
      Routes.resultView,
      page: _i9.ResultView,
    ),
    _i1.RouteDef(
      Routes.textInputView,
      page: _i10.TextInputView,
    ),
    _i1.RouteDef(
      Routes.smartReviewView,
      page: _i11.SmartReviewView,
    ),
    _i1.RouteDef(
      Routes.libraryView,
      page: _i12.LibraryView,
    ),
    _i1.RouteDef(
      Routes.mistakeBookView,
      page: _i13.MistakeBookView,
    ),
    _i1.RouteDef(
      Routes.ttsSettingsView,
      page: _i14.TtsSettingsView,
    ),
    _i1.RouteDef(
      Routes.personalCenterView,
      page: _i15.PersonalCenterView,
    ),
    _i1.RouteDef(
      Routes.previewView,
      page: _i16.PreviewView,
    ),
    _i1.RouteDef(
      Routes.recognitionView,
      page: _i17.RecognitionView,
    ),
    _i1.RouteDef(
      Routes.constructionView,
      page: _i18.ConstructionView,
    ),
    _i1.RouteDef(
      Routes.recallView,
      page: _i19.RecallView,
    ),
    _i1.RouteDef(
      Routes.learningSessionView,
      page: _i20.LearningSessionView,
    ),
    _i1.RouteDef(
      Routes.statisticsView,
      page: _i21.StatisticsView,
    ),
    _i1.RouteDef(
      Routes.emailSettingsView,
      page: _i22.EmailSettingsView,
    ),
    _i1.RouteDef(
      Routes.aboutView,
      page: _i23.AboutView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.MainView: (data) {
      final args = data.getArgs<MainViewArguments>(
        orElse: () => const MainViewArguments(),
      );
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => _i2.MainView(
            key: args.key,
            initialIndex: args.initialIndex,
            initialSubTab: args.initialSubTab),
        settings: data,
      );
    },
    _i3.HomeView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.HomeView(),
        settings: data,
      );
    },
    _i4.ScanBookView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.ScanBookView(),
        settings: data,
      );
    },
    _i5.WordListView: (data) {
      final args = data.getArgs<WordListViewArguments>(
        orElse: () => const WordListViewArguments(),
      );
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.WordListView(
            key: args.key,
            isLibrary: args.isLibrary,
            isMistakes: args.isMistakes,
            isSmartReview: args.isSmartReview),
        settings: data,
      );
    },
    _i6.ModeSelectionView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.ModeSelectionView(),
        settings: data,
      );
    },
    _i7.DictationView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.DictationView(),
        settings: data,
      );
    },
    _i8.ScanSheetView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.ScanSheetView(),
        settings: data,
      );
    },
    _i9.ResultView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.ResultView(),
        settings: data,
      );
    },
    _i10.TextInputView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.TextInputView(),
        settings: data,
      );
    },
    _i11.SmartReviewView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.SmartReviewView(),
        settings: data,
      );
    },
    _i12.LibraryView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.LibraryView(),
        settings: data,
      );
    },
    _i13.MistakeBookView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.MistakeBookView(),
        settings: data,
      );
    },
    _i14.TtsSettingsView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i14.TtsSettingsView(),
        settings: data,
      );
    },
    _i15.PersonalCenterView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i15.PersonalCenterView(),
        settings: data,
      );
    },
    _i16.PreviewView: (data) {
      final args = data.getArgs<PreviewViewArguments>(nullOk: false);
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => _i16.PreviewView(
            key: args.key, word: args.word, onNext: args.onNext),
        settings: data,
      );
    },
    _i17.RecognitionView: (data) {
      final args = data.getArgs<RecognitionViewArguments>(nullOk: false);
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => _i17.RecognitionView(
            key: args.key,
            word: args.word,
            onNext: args.onNext,
            onError: args.onError),
        settings: data,
      );
    },
    _i18.ConstructionView: (data) {
      final args = data.getArgs<ConstructionViewArguments>(nullOk: false);
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => _i18.ConstructionView(
            key: args.key,
            word: args.word,
            onNext: args.onNext,
            onError: args.onError),
        settings: data,
      );
    },
    _i19.RecallView: (data) {
      final args = data.getArgs<RecallViewArguments>(nullOk: false);
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => _i19.RecallView(
            key: args.key,
            word: args.word,
            onNext: args.onNext,
            onError: args.onError),
        settings: data,
      );
    },
    _i20.LearningSessionView: (data) {
      final args = data.getArgs<LearningSessionViewArguments>(
        orElse: () => const LearningSessionViewArguments(),
      );
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => _i20.LearningSessionView(
            key: args.key, words: args.words, source: args.source),
        settings: data,
      );
    },
    _i21.StatisticsView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i21.StatisticsView(),
        settings: data,
      );
    },
    _i22.EmailSettingsView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i22.EmailSettingsView(),
        settings: data,
      );
    },
    _i23.AboutView: (data) {
      return _i24.MaterialPageRoute<dynamic>(
        builder: (context) => const _i23.AboutView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class MainViewArguments {
  const MainViewArguments({
    this.key,
    this.initialIndex = 0,
    this.initialSubTab = 0,
  });

  final _i25.Key? key;

  final int initialIndex;

  final int initialSubTab;

  @override
  String toString() {
    return '{"key": "$key", "initialIndex": "$initialIndex", "initialSubTab": "$initialSubTab"}';
  }

  @override
  bool operator ==(covariant MainViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.initialIndex == initialIndex &&
        other.initialSubTab == initialSubTab;
  }

  @override
  int get hashCode {
    return key.hashCode ^ initialIndex.hashCode ^ initialSubTab.hashCode;
  }
}

class WordListViewArguments {
  const WordListViewArguments({
    this.key,
    this.isLibrary = false,
    this.isMistakes = false,
    this.isSmartReview = false,
  });

  final _i25.Key? key;

  final bool isLibrary;

  final bool isMistakes;

  final bool isSmartReview;

  @override
  String toString() {
    return '{"key": "$key", "isLibrary": "$isLibrary", "isMistakes": "$isMistakes", "isSmartReview": "$isSmartReview"}';
  }

  @override
  bool operator ==(covariant WordListViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.isLibrary == isLibrary &&
        other.isMistakes == isMistakes &&
        other.isSmartReview == isSmartReview;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        isLibrary.hashCode ^
        isMistakes.hashCode ^
        isSmartReview.hashCode;
  }
}

class PreviewViewArguments {
  const PreviewViewArguments({
    this.key,
    required this.word,
    required this.onNext,
  });

  final _i25.Key? key;

  final _i26.Word word;

  final void Function() onNext;

  @override
  String toString() {
    return '{"key": "$key", "word": "$word", "onNext": "$onNext"}';
  }

  @override
  bool operator ==(covariant PreviewViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.word == word && other.onNext == onNext;
  }

  @override
  int get hashCode {
    return key.hashCode ^ word.hashCode ^ onNext.hashCode;
  }
}

class RecognitionViewArguments {
  const RecognitionViewArguments({
    this.key,
    required this.word,
    required this.onNext,
    this.onError,
  });

  final _i25.Key? key;

  final _i26.Word word;

  final void Function() onNext;

  final void Function()? onError;

  @override
  String toString() {
    return '{"key": "$key", "word": "$word", "onNext": "$onNext", "onError": "$onError"}';
  }

  @override
  bool operator ==(covariant RecognitionViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.word == word &&
        other.onNext == onNext &&
        other.onError == onError;
  }

  @override
  int get hashCode {
    return key.hashCode ^ word.hashCode ^ onNext.hashCode ^ onError.hashCode;
  }
}

class ConstructionViewArguments {
  const ConstructionViewArguments({
    this.key,
    required this.word,
    required this.onNext,
    required this.onError,
  });

  final _i25.Key? key;

  final _i26.Word word;

  final void Function() onNext;

  final dynamic Function(String) onError;

  @override
  String toString() {
    return '{"key": "$key", "word": "$word", "onNext": "$onNext", "onError": "$onError"}';
  }

  @override
  bool operator ==(covariant ConstructionViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.word == word &&
        other.onNext == onNext &&
        other.onError == onError;
  }

  @override
  int get hashCode {
    return key.hashCode ^ word.hashCode ^ onNext.hashCode ^ onError.hashCode;
  }
}

class RecallViewArguments {
  const RecallViewArguments({
    this.key,
    required this.word,
    required this.onNext,
    this.onError,
  });

  final _i25.Key? key;

  final _i26.Word word;

  final void Function() onNext;

  final void Function()? onError;

  @override
  String toString() {
    return '{"key": "$key", "word": "$word", "onNext": "$onNext", "onError": "$onError"}';
  }

  @override
  bool operator ==(covariant RecallViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.word == word &&
        other.onNext == onNext &&
        other.onError == onError;
  }

  @override
  int get hashCode {
    return key.hashCode ^ word.hashCode ^ onNext.hashCode ^ onError.hashCode;
  }
}

class LearningSessionViewArguments {
  const LearningSessionViewArguments({
    this.key,
    this.words,
    this.source,
  });

  final _i25.Key? key;

  final List<_i26.Word>? words;

  final String? source;

  @override
  String toString() {
    return '{"key": "$key", "words": "$words", "source": "$source"}';
  }

  @override
  bool operator ==(covariant LearningSessionViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.words == words && other.source == source;
  }

  @override
  int get hashCode {
    return key.hashCode ^ words.hashCode ^ source.hashCode;
  }
}

extension NavigatorStateExtension on _i27.NavigationService {
  Future<dynamic> navigateToMainView({
    _i25.Key? key,
    int initialIndex = 0,
    int initialSubTab = 0,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.mainView,
        arguments: MainViewArguments(
            key: key, initialIndex: initialIndex, initialSubTab: initialSubTab),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToScanBookView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.scanBookView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToWordListView({
    _i25.Key? key,
    bool isLibrary = false,
    bool isMistakes = false,
    bool isSmartReview = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.wordListView,
        arguments: WordListViewArguments(
            key: key,
            isLibrary: isLibrary,
            isMistakes: isMistakes,
            isSmartReview: isSmartReview),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToModeSelectionView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.modeSelectionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDictationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.dictationView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToScanSheetView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.scanSheetView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToResultView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.resultView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToTextInputView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.textInputView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSmartReviewView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.smartReviewView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLibraryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.libraryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMistakeBookView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.mistakeBookView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToTtsSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.ttsSettingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPersonalCenterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.personalCenterView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPreviewView({
    _i25.Key? key,
    required _i26.Word word,
    required void Function() onNext,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.previewView,
        arguments: PreviewViewArguments(key: key, word: word, onNext: onNext),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRecognitionView({
    _i25.Key? key,
    required _i26.Word word,
    required void Function() onNext,
    void Function()? onError,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.recognitionView,
        arguments: RecognitionViewArguments(
            key: key, word: word, onNext: onNext, onError: onError),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToConstructionView({
    _i25.Key? key,
    required _i26.Word word,
    required void Function() onNext,
    required dynamic Function(String) onError,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.constructionView,
        arguments: ConstructionViewArguments(
            key: key, word: word, onNext: onNext, onError: onError),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRecallView({
    _i25.Key? key,
    required _i26.Word word,
    required void Function() onNext,
    void Function()? onError,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.recallView,
        arguments: RecallViewArguments(
            key: key, word: word, onNext: onNext, onError: onError),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLearningSessionView({
    _i25.Key? key,
    List<_i26.Word>? words,
    String? source,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.learningSessionView,
        arguments: LearningSessionViewArguments(
            key: key, words: words, source: source),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStatisticsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.statisticsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToEmailSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.emailSettingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAboutView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.aboutView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMainView({
    _i25.Key? key,
    int initialIndex = 0,
    int initialSubTab = 0,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.mainView,
        arguments: MainViewArguments(
            key: key, initialIndex: initialIndex, initialSubTab: initialSubTab),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithScanBookView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.scanBookView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithWordListView({
    _i25.Key? key,
    bool isLibrary = false,
    bool isMistakes = false,
    bool isSmartReview = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.wordListView,
        arguments: WordListViewArguments(
            key: key,
            isLibrary: isLibrary,
            isMistakes: isMistakes,
            isSmartReview: isSmartReview),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithModeSelectionView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.modeSelectionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDictationView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.dictationView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithScanSheetView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.scanSheetView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithResultView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.resultView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithTextInputView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.textInputView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSmartReviewView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.smartReviewView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLibraryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.libraryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMistakeBookView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.mistakeBookView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithTtsSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.ttsSettingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPersonalCenterView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.personalCenterView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPreviewView({
    _i25.Key? key,
    required _i26.Word word,
    required void Function() onNext,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.previewView,
        arguments: PreviewViewArguments(key: key, word: word, onNext: onNext),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRecognitionView({
    _i25.Key? key,
    required _i26.Word word,
    required void Function() onNext,
    void Function()? onError,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.recognitionView,
        arguments: RecognitionViewArguments(
            key: key, word: word, onNext: onNext, onError: onError),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithConstructionView({
    _i25.Key? key,
    required _i26.Word word,
    required void Function() onNext,
    required dynamic Function(String) onError,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.constructionView,
        arguments: ConstructionViewArguments(
            key: key, word: word, onNext: onNext, onError: onError),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRecallView({
    _i25.Key? key,
    required _i26.Word word,
    required void Function() onNext,
    void Function()? onError,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.recallView,
        arguments: RecallViewArguments(
            key: key, word: word, onNext: onNext, onError: onError),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLearningSessionView({
    _i25.Key? key,
    List<_i26.Word>? words,
    String? source,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.learningSessionView,
        arguments: LearningSessionViewArguments(
            key: key, words: words, source: source),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStatisticsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.statisticsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithEmailSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.emailSettingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAboutView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.aboutView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
