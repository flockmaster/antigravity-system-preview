import 'package:flutter_test/flutter_test.dart';
import 'package:word_assistant/app/car_owner_app.dart';
import 'package:word_assistant/app/app.locator.dart';
import 'package:word_assistant/core/services/database_service.dart';

class FakeDatabaseService extends DatabaseService {
  @override
  Future<List<Map<String, dynamic>>> getSessionHistory() async => [];

  @override
  Future<Set<String>> getRetroCheckinDates() async => <String>{};

  @override
  Future<int> getRetroCheckinCountForMonth(DateTime date) async => 0;

  @override
  Future<bool> insertRetroCheckin(String dateKey, int pointsCost) async => true;

  @override
  Future<bool> hasDailyReward(String dateKey, String type) async => false;

  @override
  Future<bool> insertDailyReward(String dateKey, String type, int points) async => true;

  @override
  Future<bool> isGoldEligibleForDateKey(String dateKey) async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupLocator();
    locator.unregister<DatabaseService>();
    locator.registerSingleton<DatabaseService>(FakeDatabaseService());
  });

  tearDownAll(() async {
    await locator.reset();
  });

  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // 构建应用并触发一帧
    await tester.pumpWidget(const DictationPalApp());
    await tester.pump();
  });
}
