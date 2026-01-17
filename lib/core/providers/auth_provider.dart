import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required this.authService}) {
    _loadStoredUser();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> _loadStoredUser() async {
    try {
      final userData = await authService.getStoredUser();
      if (userData != null) {
        _user = User.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> login(String username, String password, {String? odooUrl, String? odooDatabase}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await authService.login(
        username, 
        password,
        odooUrl: odooUrl,
        odooDatabase: odooDatabase,
      );
      // Safely convert Map<dynamic, dynamic> to Map<String, dynamic>
      final userData = result['user'];
      _user = User.fromJson(Map<String, dynamic>.from(userData as Map));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
