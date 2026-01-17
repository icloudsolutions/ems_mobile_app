import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart' if (dart.library.html) 'firebase_stub.dart' show FirebaseMessaging, RemoteMessage, NotificationSettings;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import 'storage_service.dart';
import 'api_service.dart';

class NotificationService {
  final dynamic _firebaseMessaging = kIsWeb ? null : FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final StorageService _storageService;
  final ApiService? _apiService;
  
  String? _fcmToken;
  final List<AppNotification> _notifications = [];
  final StreamController<AppNotification> _notificationController = StreamController<AppNotification>.broadcast();

  NotificationService({
    required StorageService storageService,
    ApiService? apiService,
  }) : _storageService = storageService, _apiService = apiService;

  Stream<AppNotification> get notificationStream => _notificationController.stream;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (kIsWeb) {
      // Skip Firebase initialization on web
      if (kDebugMode) {
        print('NotificationService: Skipping Firebase initialization on web');
      }
      await _loadStoredNotifications();
      return;
    }

    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    await _getFCMToken();

    // Configure message handlers
    _configureMessageHandlers();

    // Load stored notifications
    await _loadStoredNotifications();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb || _firebaseMessaging == null) return;
    
    final messaging = _firebaseMessaging as FirebaseMessaging;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // Request local notification permissions (Android)
    final androidSettings = await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (kDebugMode) {
      print('Android notification permission: $androidSettings');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'ems_notifications',
      'EMS Notifications',
      description: 'Notifications for Education Management System',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _getFCMToken() async {
    if (kIsWeb || _firebaseMessaging == null) return;
    
    try {
      final messaging = _firebaseMessaging as FirebaseMessaging;
      _fcmToken = await messaging.getToken();
      if (_fcmToken != null) {
        await _storageService.saveString('fcm_token', _fcmToken!);
        
        // Send token to backend
        if (_apiService != null) {
          await _sendTokenToBackend(_fcmToken!);
        }

        if (kDebugMode) {
          print('FCM Token: $_fcmToken');
        }
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _storageService.saveString('fcm_token', newToken);
        if (_apiService != null) {
          _sendTokenToBackend(newToken);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      // Get user ID from storage
      final userId = _storageService.getInt('user_id');
      if (userId == null) return;

      // Send token to Odoo backend
      await _apiService?.callRPC(
        'res.users',
        'write',
        [
          [userId],
          {'fcm_token': token}
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending token to backend: $e');
      }
    }
  }

  void _configureMessageHandlers() {
    if (kIsWeb || _firebaseMessaging == null) return;
    
    final messaging = _firebaseMessaging as FirebaseMessaging;
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((dynamic message) {
      if (kDebugMode) {
        print('Foreground message received: ${(message as RemoteMessage).messageId}');
      }
      _handleNotification(message);
    });

    // Handle background messages (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((dynamic message) {
      if (kDebugMode) {
        print('Notification opened app: ${(message as RemoteMessage).messageId}');
      }
      _handleNotificationTap(message);
    });

    // Check if app was opened from a notification
    messaging.getInitialMessage().then((dynamic message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
  }

  Future<void> _handleNotification(dynamic message) async {
    if (kIsWeb) return; // Skip on web
    final remoteMessage = message as RemoteMessage;
    final notification = AppNotification(
      id: remoteMessage.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: remoteMessage.notification?.title ?? 'New Notification',
      body: remoteMessage.notification?.body ?? '',
      type: remoteMessage.data['type'] as String?,
      data: remoteMessage.data,
      timestamp: remoteMessage.sentTime ?? DateTime.now(),
    );

    // Add to list
    _notifications.insert(0, notification);
    await _saveNotifications();

    // Show local notification
    await _showLocalNotification(notification);

    // Emit to stream
    _notificationController.add(notification);
  }

  Future<void> _showLocalNotification(AppNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'ems_notifications',
      'EMS Notifications',
      channelDescription: 'Notifications for Education Management System',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: notification.id,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final notification = _notifications.firstWhere(
        (n) => n.id == response.payload,
        orElse: () => AppNotification(
          id: response.payload!,
          title: '',
          body: '',
          timestamp: DateTime.now(),
        ),
      );
      _handleNotificationTap(notification);
    }
  }

  void _handleNotificationTap(dynamic message) {
    if (kIsWeb) return; // Skip on web
    
    // Extract notification data
    AppNotification? notification;
    
    if (message is RemoteMessage) {
      notification = AppNotification(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        type: message.data['type'] as String?,
        data: message.data,
        timestamp: message.sentTime ?? DateTime.now(),
      );
    } else if (message is AppNotification) {
      notification = message;
    }

    if (notification != null) {
      // Mark as read
      _markAsRead(notification.id);
      
      // Emit to stream for navigation handling
      _notificationController.add(notification);
    }
  }

  Future<void> _loadStoredNotifications() async {
    try {
      final stored = _storageService.getString('notifications');
      if (stored != null && stored.isNotEmpty) {
        // Simple storage - in production, use proper JSON serialization
        // For now, notifications are kept in memory
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading stored notifications: $e');
      }
    }
  }

  Future<void> _saveNotifications() async {
    try {
      // Save only recent notifications (last 50)
      final recent = _notifications.take(50).toList();
      // Simple storage - in production, use proper JSON serialization
      // For now, we keep notifications in memory
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notifications: $e');
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveNotifications();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void dispose() {
    _notificationController.close();
  }
}
