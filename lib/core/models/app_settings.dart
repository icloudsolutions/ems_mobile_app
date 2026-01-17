class AppSettings {
  final String? odooUrl;
  final String? odooDatabase;
  final String? firebaseApiKey;
  final String? firebaseAppId;
  final String? firebaseMessagingSenderId;
  final String? firebaseProjectId;
  final String? firebaseStorageBucket;
  final String? firebaseAuthDomain;
  final bool notificationsEnabled;
  final bool notificationsSound;
  final bool notificationsVibration;

  AppSettings({
    this.odooUrl,
    this.odooDatabase,
    this.firebaseApiKey,
    this.firebaseAppId,
    this.firebaseMessagingSenderId,
    this.firebaseProjectId,
    this.firebaseStorageBucket,
    this.firebaseAuthDomain,
    this.notificationsEnabled = true,
    this.notificationsSound = true,
    this.notificationsVibration = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      odooUrl: json['odoo_url'] as String?,
      odooDatabase: json['odoo_database'] as String?,
      firebaseApiKey: json['firebase_api_key'] as String?,
      firebaseAppId: json['firebase_app_id'] as String?,
      firebaseMessagingSenderId: json['firebase_messaging_sender_id'] as String?,
      firebaseProjectId: json['firebase_project_id'] as String?,
      firebaseStorageBucket: json['firebase_storage_bucket'] as String?,
      firebaseAuthDomain: json['firebase_auth_domain'] as String?,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      notificationsSound: json['notifications_sound'] as bool? ?? true,
      notificationsVibration: json['notifications_vibration'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'odoo_url': odooUrl,
      'odoo_database': odooDatabase,
      'firebase_api_key': firebaseApiKey,
      'firebase_app_id': firebaseAppId,
      'firebase_messaging_sender_id': firebaseMessagingSenderId,
      'firebase_project_id': firebaseProjectId,
      'firebase_storage_bucket': firebaseStorageBucket,
      'firebase_auth_domain': firebaseAuthDomain,
      'notifications_enabled': notificationsEnabled,
      'notifications_sound': notificationsSound,
      'notifications_vibration': notificationsVibration,
    };
  }

  AppSettings copyWith({
    String? odooUrl,
    String? odooDatabase,
    String? firebaseApiKey,
    String? firebaseAppId,
    String? firebaseMessagingSenderId,
    String? firebaseProjectId,
    String? firebaseStorageBucket,
    String? firebaseAuthDomain,
    bool? notificationsEnabled,
    bool? notificationsSound,
    bool? notificationsVibration,
  }) {
    return AppSettings(
      odooUrl: odooUrl ?? this.odooUrl,
      odooDatabase: odooDatabase ?? this.odooDatabase,
      firebaseApiKey: firebaseApiKey ?? this.firebaseApiKey,
      firebaseAppId: firebaseAppId ?? this.firebaseAppId,
      firebaseMessagingSenderId: firebaseMessagingSenderId ?? this.firebaseMessagingSenderId,
      firebaseProjectId: firebaseProjectId ?? this.firebaseProjectId,
      firebaseStorageBucket: firebaseStorageBucket ?? this.firebaseStorageBucket,
      firebaseAuthDomain: firebaseAuthDomain ?? this.firebaseAuthDomain,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationsSound: notificationsSound ?? this.notificationsSound,
      notificationsVibration: notificationsVibration ?? this.notificationsVibration,
    );
  }

  bool get isFirebaseConfigured {
    return firebaseApiKey != null &&
        firebaseAppId != null &&
        firebaseMessagingSenderId != null &&
        firebaseProjectId != null;
  }
}
