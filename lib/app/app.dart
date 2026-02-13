import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import '../core/network/api_client.dart';
import '../core/services/ai_service.dart';
import '../core/services/dictation_service.dart';
import '../core/services/database_service.dart';
import '../core/services/tts_service.dart';
import '../core/services/session_service.dart';
import '../core/services/audio_manager.dart';
import '../core/services/speech_service.dart';
import '../core/services/user_service.dart';
import '../core/services/email_service.dart';

import '../ui/views/home/home_view.dart';
import '../ui/views/scan_book/scan_book_view.dart';
import '../ui/views/word_list/word_list_view.dart';
import '../ui/views/mode_selection/mode_selection_view.dart';
import '../ui/views/dictation/dictation_view.dart';
import '../ui/views/scan_sheet/scan_sheet_view.dart';
import '../ui/views/result/result_view.dart';
import '../ui/views/text_input/text_input_view.dart';
import '../ui/views/main/main_view.dart';
import '../ui/views/smart_review/smart_review_view.dart';
import '../ui/views/library/library_view.dart';
import '../ui/views/mistake_book/mistake_book_view.dart';
import '../ui/views/tts_settings/tts_settings_view.dart';
import '../ui/views/personal_center/personal_center_view.dart';
import '../ui/views/learning_modes/preview/preview_view.dart';
import '../ui/views/learning_modes/recognition/recognition_view.dart';
import '../ui/views/learning_modes/construction/construction_view.dart';
import '../ui/views/learning_modes/recall/recall_view.dart';
import '../ui/views/learning_modes/learning_session_view.dart';
import '../ui/views/statistics/statistics_view.dart';
import '../ui/views/email_settings/email_settings_view.dart';
import '../ui/views/about/about_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: MainView, initial: true),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: ScanBookView),
    MaterialRoute(page: WordListView),
    MaterialRoute(page: ModeSelectionView),
    MaterialRoute(page: DictationView),
    MaterialRoute(page: ScanSheetView),
    MaterialRoute(page: ResultView),
    MaterialRoute(page: TextInputView),
    MaterialRoute(page: SmartReviewView),
    MaterialRoute(page: LibraryView),
    MaterialRoute(page: MistakeBookView),
    MaterialRoute(page: TtsSettingsView),
    MaterialRoute(page: PersonalCenterView),
    MaterialRoute(page: PreviewView),
    MaterialRoute(page: RecognitionView),
    MaterialRoute(page: ConstructionView),
    MaterialRoute(page: RecallView),
    MaterialRoute(page: LearningSessionView),
    MaterialRoute(page: StatisticsView),
    MaterialRoute(page: EmailSettingsView),
    MaterialRoute(page: AboutView),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: ApiClient),
    LazySingleton(classType: AiService),
    LazySingleton(classType: DictationService),
    LazySingleton(classType: DatabaseService),
    LazySingleton(classType: TtsService),
    LazySingleton(classType: SessionService),
    LazySingleton(classType: AudioManager),
    LazySingleton(classType: SpeechService),
    LazySingleton(classType: UserService),
    LazySingleton(classType: EmailService),
  ],
)
class App {}