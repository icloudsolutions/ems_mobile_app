import 'package:firebase_core/firebase_core.dart' if (dart.library.html) 'firebase_stub.dart' show Firebase, FirebaseOptions;
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';

class FirebaseConfigService {
  static Future<FirebaseOptions?> getFirebaseOptions(AppSettings settings) async {
    if (!settings.isFirebaseConfigured) {
      if (kDebugMode) {
        print('Firebase not configured. Please configure in app settings.');
      }
      return null;
    }

    try {
      // Create FirebaseOptions with values from settings
      // Note: This approach works for basic initialization
      // For production, consider using firebase_options.dart generated file
      return FirebaseOptions(
        apiKey: settings.firebaseApiKey!,
        appId: settings.firebaseAppId!,
        messagingSenderId: settings.firebaseMessagingSenderId!,
        projectId: settings.firebaseProjectId!,
        storageBucket: settings.firebaseStorageBucket ?? '${settings.firebaseProjectId}.appspot.com',
        authDomain: settings.firebaseAuthDomain ?? '${settings.firebaseProjectId}.firebaseapp.com',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating Firebase options: $e');
      }
      return null;
    }
  }

  static Future<bool> initializeFirebase(AppSettings settings) async {
    if (kIsWeb) {
      if (kDebugMode) {
        print('Firebase not supported on web platform');
      }
      return false;
    }
    
    try {
      // Check if Firebase is already initialized
      try {
        Firebase.app();
        if (kDebugMode) {
          print('Firebase already initialized');
        }
        return true;
      } catch (e) {
        // Firebase not initialized, proceed
      }

      final options = await getFirebaseOptions(settings);
      if (options == null) {
        return false;
      }

      await Firebase.initializeApp(options: options);
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
        print('Error details: ${e.toString()}');
      }
      return false;
    }
  }

  static Future<bool> reinitializeFirebase(AppSettings settings) async {
    if (kIsWeb) {
      return false;
    }
    
    try {
      // Delete existing Firebase app if it exists
      try {
        await Firebase.app().delete();
      } catch (e) {
        // App doesn't exist or already deleted
      }

      // Initialize with new settings
      return await initializeFirebase(settings);
    } catch (e) {
      if (kDebugMode) {
        print('Error reinitializing Firebase: $e');
      }
      return false;
    }
  }
}
