// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../core/network/api_client.dart';
import '../core/services/ai_service.dart';
import '../core/services/audio_manager.dart';
import '../core/services/database_service.dart';
import '../core/services/dictation_service.dart';
import '../core/services/email_service.dart';
import '../core/services/session_service.dart';
import '../core/services/speech_service.dart';
import '../core/services/tts_service.dart';
import '../core/services/user_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => ApiClient());
  locator.registerLazySingleton(() => AiService());
  locator.registerLazySingleton(() => DictationService());
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => TtsService());
  locator.registerLazySingleton(() => SessionService());
  locator.registerLazySingleton(() => AudioManager());
  locator.registerLazySingleton(() => SpeechService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => EmailService());
}
