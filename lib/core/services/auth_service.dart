import 'dart:convert';
import 'package:odoo_rpc/odoo_rpc.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService apiService;
  final StorageService storageService;

  AuthService({
    required this.apiService,
    required this.storageService,
  });

  Future<Map<String, dynamic>> login(String username, String password, {String? odooUrl, String? odooDatabase}) async {
    try {
      // Use provided URL or fallback to default
      final baseUrl = odooUrl ?? AppConfig.baseUrl;
      final database = odooDatabase ?? AppConfig.database;
      
      // Update API service with the URL and database
      apiService.updateBaseUrl(baseUrl, database);
      
      // Authenticate with Odoo using odoo_rpc
      final session = await apiService.authenticate(database, username, password);
      
      // Get user ID from session
      final uid = session.userId;
      if (uid == 0) {
        throw Exception('Invalid credentials');
      }

      // Get user data
      final userDataList = await apiService.read(
        'res.users',
        [uid],
        fields: ['id', 'name', 'login', 'partner_id'],
      );
      
      if (userDataList.isEmpty) {
        throw Exception('User data not found');
      }
      
      // Safely convert the response data
      final userData = Map<String, dynamic>.from(userDataList[0] as Map);
      
      // Set session in API service
      apiService.setSession(session);
      
      // Determine user role by checking which related record exists
      // This is more reliable than using groups_id (which doesn't exist in Odoo 19)
      // Note: If user doesn't have access to these models, we'll default to 'parent'
      String role = 'parent'; // Default
      Map<String, dynamic> userProfile = {};
      
      // Check for student record first
      try {
        final studentResult = await apiService.searchRead(
          'ics.student',
          domain: [['user_id', '=', uid]],
          fields: ['id'],
          limit: 1,
        );
        final studentList = studentResult as List;
        if (studentList.isNotEmpty) {
          role = 'student';
          userProfile = await _getStudentProfile(uid);
        }
      } catch (e) {
        // Student record doesn't exist, user doesn't have access, or error
        // Continue checking other roles
      }
      
      // If not student, check for teacher
      if (role == 'parent') {
        try {
          final teacherResult = await apiService.searchRead(
            'ics.teacher',
            domain: [['user_id', '=', uid]],
            fields: ['id'],
            limit: 1,
          );
          final teacherList = teacherResult as List;
          if (teacherList.isNotEmpty) {
            role = 'teacher';
            userProfile = await _getTeacherProfile(uid);
          }
        } catch (e) {
          // Teacher record doesn't exist, user doesn't have access, or error
          // Continue checking parent
        }
      }
      
      // If not student or teacher, check for parent (or default to parent)
      if (role == 'parent') {
        try {
          userProfile = await _getParentProfile(uid);
        } catch (e) {
          // Parent record might not exist or user doesn't have access
          // We'll default to parent role with empty profile
        }
      }
      
      // Save to storage
      await storageService.saveSecure(AppConfig.keyAccessToken, password);
      await storageService.saveInt(AppConfig.keyUserId, uid);
      await storageService.saveString(AppConfig.keyUserRole, role);
      await storageService.saveString(AppConfig.keyUserData, jsonEncode({
        ...userData,
        ...userProfile,
        'role': role,
      }));

      return {
        'uid': uid,
        'session_id': session.id,
        'user': {
          ...userData,
          ...userProfile,
          'role': role,
        },
      };
    } on OdooException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _getParentProfile(int uid) async {
    try {
      final result = await apiService.searchRead(
        'ics.parent',
        domain: [['user_id', '=', uid]],
        fields: ['id', 'name', 'email', 'mobile', 'student_ids'],
      );
      
      // Convert result to List and handle type conversion
      final resultList = result as List;
      if (resultList.isNotEmpty) {
        final parentData = Map<String, dynamic>.from(resultList[0] as Map);
        return {
          'parent_id': parentData['id'],
          'parent_data': parentData,
        };
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> _getStudentProfile(int uid) async {
    try {
      final result = await apiService.searchRead(
        'ics.student',
        domain: [['user_id', '=', uid]],
        fields: ['id', 'name', 'student_number', 'grade_id', 'division_id', 'school_id'],
      );
      
      // Convert result to List and handle type conversion
      final resultList = result as List;
      if (resultList.isNotEmpty) {
        final studentData = Map<String, dynamic>.from(resultList[0] as Map);
        return {
          'student_id': studentData['id'],
          'student_data': studentData,
        };
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> _getTeacherProfile(int uid) async {
    try {
      final result = await apiService.searchRead(
        'ics.teacher',
        domain: [['user_id', '=', uid]],
        fields: ['id', 'name', 'email', 'mobile', 'subject_ids'],
      );
      
      // Convert result to List and handle type conversion
      final resultList = result as List;
      if (resultList.isNotEmpty) {
        final teacherData = Map<String, dynamic>.from(resultList[0] as Map);
        return {
          'teacher_id': teacherData['id'],
          'teacher_data': teacherData,
        };
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<void> logout() async {
    try {
      // Destroy session in Odoo
      await apiService.client.destroySession();
    } catch (e) {
      // Ignore errors during logout (session might already be expired)
    }
    apiService.clearSession();
    await storageService.clear();
  }

  Future<Map<String, dynamic>?> getStoredUser() async {
    final userDataStr = storageService.getString(AppConfig.keyUserData);
    if (userDataStr != null) {
      final decoded = jsonDecode(userDataStr);
      return Map<String, dynamic>.from(decoded as Map);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await storageService.getSecure(AppConfig.keyAccessToken);
    final uid = storageService.getInt(AppConfig.keyUserId);
    return token != null && uid != null;
  }
}
