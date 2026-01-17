import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
// Firebase imports - only on non-web platforms (dart.library.io is available on mobile/desktop but not web)
import 'package:firebase_core/firebase_core.dart' if (dart.library.html) 'core/services/firebase_stub.dart' show Firebase, FirebaseOptions;
import 'package:firebase_messaging/firebase_messaging.dart' if (dart.library.html) 'core/services/firebase_stub.dart' show FirebaseMessaging, RemoteMessage;

import 'core/config/app_config.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/firebase_config_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/error_logger_service.dart';
import 'core/utils/error_handler.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/student_provider.dart';
import 'core/providers/parent_provider.dart';
import 'core/providers/teacher_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// Background message handler (not supported on web)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(dynamic message) async {
  if (kIsWeb) return; // Skip on web
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Background message received: ${(message as dynamic).messageId}');
  }
  // Handle background message - notifications will be processed when app opens
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  
  // Initialize error logger
  final errorLogger = ErrorLoggerService(storageService: storageService);
  ErrorHandler.initialize(errorLogger);
  
  // Log app start (don't let logging errors crash the app)
  try {
    await errorLogger.info('App starting...');
  } catch (e) {
    if (kDebugMode) {
      print('Warning: Error logger initialization issue: $e');
    }
  }
  
  final settingsService = SettingsService(storageService: storageService);
  final settings = await settingsService.loadSettings();
  
  // Initialize Firebase if configured (skip on web due to compatibility issues)
  bool firebaseInitialized = false;
  if (!kIsWeb && settings.isFirebaseConfigured) {
    firebaseInitialized = await FirebaseConfigService.initializeFirebase(settings);
    if (firebaseInitialized) {
      // Set up background message handler (not supported on web)
      try {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      } catch (e, stackTrace) {
        await errorLogger.error(
          'Error setting up background message handler',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  } else {
    if (kDebugMode) {
      if (kIsWeb) {
        print('Firebase Messaging not supported on web. Skipping initialization.');
      } else {
        print('Firebase not configured. Configure in app settings to enable push notifications.');
      }
    }
  }
  
  final apiService = ApiService();
  final authService = AuthService(apiService: apiService, storageService: storageService);
  
  // Initialize notification service only if Firebase is configured
  NotificationService? notificationService;
  if (firebaseInitialized) {
    notificationService = NotificationService(
      storageService: storageService,
      apiService: apiService,
    );
    // Initialize notifications
    await notificationService.initialize();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(settingsService: settingsService)),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService: authService)),
        ChangeNotifierProvider(create: (_) => StudentProvider(apiService: apiService)),
        ChangeNotifierProvider(create: (_) => ParentProvider(apiService: apiService)),
        ChangeNotifierProvider(create: (_) => TeacherProvider(apiService: apiService)),
        if (notificationService != null)
          ChangeNotifierProvider(create: (_) => NotificationProvider(notificationService: notificationService!)),
      ],
      child: const EMSApp(),
    ),
  );
}

class EMSApp extends StatelessWidget {
  const EMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EMS Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
