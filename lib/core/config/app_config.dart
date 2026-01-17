import '../services/storage_service.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class AppConfig {
  // API Configuration - will be loaded from settings
  static String get baseUrl {
    // Try to get from storage, fallback to default
    final storage = StorageService();
    final settingsService = SettingsService(storageService: storage);
    // This is a synchronous getter, so we'll use a different approach
    // We'll pass the URL dynamically through services
    return 'https://your-odoo-instance.com'; // Default fallback
  }
  
  static String getBaseUrlFromSettings(AppSettings settings) {
    return settings.odooUrl ?? 'https://your-odoo-instance.com';
  }
  
  static String getDatabaseFromSettings(AppSettings settings) {
    return settings.odooDatabase ?? 'your_database';
  }
  
  static const String apiPath = '/jsonrpc';
  static const String database = 'your_database'; // Fallback
  
  // API Timeout
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserData = 'user_data';
  static const String keyLanguage = 'language';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
}
