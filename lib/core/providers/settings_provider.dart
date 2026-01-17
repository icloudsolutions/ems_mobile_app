import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService settingsService;
  AppSettings _settings = AppSettings();
  bool _isLoading = false;

  SettingsProvider({required this.settingsService}) {
    _loadSettings();
  }

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await settingsService.loadSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading settings: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOdooConfig({
    String? url,
    String? database,
  }) async {
    try {
      await settingsService.updateOdooConfig(
        url: url,
        database: database,
      );
      await _loadSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Odoo config: $e');
      }
      rethrow;
    }
  }

  Future<void> updateFirebaseConfig({
    String? apiKey,
    String? appId,
    String? messagingSenderId,
    String? projectId,
    String? storageBucket,
    String? authDomain,
  }) async {
    try {
      await settingsService.updateFirebaseConfig(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
        authDomain: authDomain,
      );
      await _loadSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Firebase config: $e');
      }
      rethrow;
    }
  }

  Future<void> updateNotificationSettings({
    bool? enabled,
    bool? sound,
    bool? vibration,
  }) async {
    try {
      await settingsService.updateNotificationSettings(
        enabled: enabled,
        sound: sound,
        vibration: vibration,
      );
      await _loadSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notification settings: $e');
      }
      rethrow;
    }
  }
}
