import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_queue/app/app.dart';
import 'package:agri_queue/services/local_storage_service.dart';
import 'package:agri_queue/services/mock_auth_service.dart';
import 'package:agri_queue/services/mock_data_service.dart';

void main() {
  testWidgets('AgriQueueApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    final auth = MockAuthService();
    final data = MockDataService();

    await tester.pumpWidget(
      AgriQueueApp(
        localStorageService: storage,
        mockAuthService: auth,
        mockDataService: data,
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial screen is Language Screen
    expect(find.text('AgriQueue'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
