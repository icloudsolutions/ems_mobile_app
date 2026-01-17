import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService notificationService;
  
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider({required this.notificationService}) {
    _loadNotifications();
    _setupListener();
  }

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => notificationService.unreadCount;

  void _setupListener() {
    notificationService.notificationStream.listen((notification) {
      _notifications.insert(0, notification);
      notifyListeners();
    });
  }

  void _loadNotifications() {
    _notifications = notificationService.notifications;
    notifyListeners();
  }

  Future<void> refreshNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _loadNotifications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await notificationService.deleteNotification(notificationId);
    _loadNotifications();
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await notificationService.markAllAsRead();
    _loadNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    await notificationService.deleteNotification(notificationId);
    _loadNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    await notificationService.clearAllNotifications();
    _notifications.clear();
    notifyListeners();
  }
}
