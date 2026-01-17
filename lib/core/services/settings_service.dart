import 'dart:convert';
import '../models/app_settings.dart';
import 'storage_service.dart';

class SettingsService {
  final StorageService _storageService;
  static const String _settingsKey = 'app_settings';

  SettingsService({required StorageService storageService})
      : _storageService = storageService;

  Future<AppSettings> loadSettings() async {
    try {
      final settingsJson = _storageService.getString(_settingsKey);
      if (settingsJson != null) {
        final decoded = jsonDecode(settingsJson);
        final json = Map<String, dynamic>.from(decoded as Map);
        return AppSettings.fromJson(json);
      }
    } catch (e) {
      // Return default settings if loading fails
    }
    return AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    try {
      final json = jsonEncode(settings.toJson());
      await _storageService.saveString(_settingsKey, json);
    } catch (e) {
      throw Exception('Failed to save settings: $e');
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
    final current = await loadSettings();
    final updated = current.copyWith(
      firebaseApiKey: apiKey,
      firebaseAppId: appId,
      firebaseMessagingSenderId: messagingSenderId,
      firebaseProjectId: projectId,
      firebaseStorageBucket: storageBucket,
      firebaseAuthDomain: authDomain,
    );
    await saveSettings(updated);
  }

  Future<void> updateOdooConfig({
    String? url,
    String? database,
  }) async {
    final current = await loadSettings();
    final updated = current.copyWith(
      odooUrl: url,
      odooDatabase: database,
    );
    await saveSettings(updated);
  }

  Future<void> updateNotificationSettings({
    bool? enabled,
    bool? sound,
    bool? vibration,
  }) async {
    final current = await loadSettings();
    final updated = current.copyWith(
      notificationsEnabled: enabled,
      notificationsSound: sound,
      notificationsVibration: vibration,
    );
    await saveSettings(updated);
  }
}
