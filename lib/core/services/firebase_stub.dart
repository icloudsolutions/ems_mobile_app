// Stub file for Firebase on web platform
// This file provides empty implementations to avoid compilation errors on web

class Firebase {
  static Future<void> initializeApp({dynamic options}) async {}
  static dynamic app() {
    throw Exception('Firebase not available on web');
  }
}

class FirebaseMessaging {
  static FirebaseMessaging get instance => FirebaseMessaging();
  Future<String?> getToken() => Future.value(null);
  Stream<String> get onTokenRefresh => const Stream.empty();
  static Stream<RemoteMessage> get onMessage => const Stream.empty();
  static Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();
  Future<RemoteMessage?> getInitialMessage() => Future.value(null);
  static void onBackgroundMessage(dynamic Function(dynamic) handler) {}
  Future<NotificationSettings> requestPermission({
    bool? alert,
    bool? badge,
    bool? sound,
    bool? provisional,
  }) => Future.value(NotificationSettings());
}

class RemoteMessage {
  String? get messageId => null;
  dynamic get notification => null;
  Map<String, dynamic> get data => {};
  DateTime? get sentTime => null;
}

class NotificationSettings {
  dynamic get authorizationStatus => null;
}

class FirebaseOptions {
  final String? apiKey;
  final String? appId;
  final String? messagingSenderId;
  final String? projectId;
  final String? storageBucket;
  final String? authDomain;
  
  FirebaseOptions({
    this.apiKey,
    this.appId,
    this.messagingSenderId,
    this.projectId,
    this.storageBucket,
    this.authDomain,
  });
}
