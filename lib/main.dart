import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'services/local_storage_service.dart';
import 'services/mock_auth_service.dart';
import 'services/mock_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar styling for clean farmer UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final localStorageService = LocalStorageService();
  final mockAuthService = MockAuthService();
  final mockDataService = MockDataService();

  runApp(
    AgriQueueApp(
      localStorageService: localStorageService,
      mockAuthService: mockAuthService,
      mockDataService: mockDataService,
    ),
  );
}
