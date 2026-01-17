import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/parent/screens/parent_dashboard_screen.dart';
import '../../features/teacher/screens/teacher_dashboard_screen.dart';
import '../../features/student/screens/student_profile_screen.dart';
import '../../features/student/screens/attendance_screen.dart';
import '../../features/student/screens/grades_screen.dart';
import '../../features/student/screens/fees_screen.dart';
import '../../features/student/screens/assignments_screen.dart';
import '../../features/student/screens/timetable_screen.dart';
import '../../features/student/screens/exams_screen.dart';
import '../../features/student/screens/report_card_screen.dart';
import '../../features/parent/screens/children_list_screen.dart';
import '../../features/parent/screens/child_detail_screen.dart';
import '../../features/teacher/screens/class_students_screen.dart';
import '../../features/teacher/screens/mark_attendance_screen.dart';
import '../../features/teacher/screens/assignments_screen.dart' as teacher;
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/common/screens/messages_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return _getHomeRoute(authProvider.user?.role);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const StudentProfileScreen(),
          ),
          GoRoute(
            path: 'attendance',
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: 'grades',
            builder: (context, state) => const GradesScreen(),
          ),
          GoRoute(
            path: 'fees',
            builder: (context, state) => const FeesScreen(),
          ),
          GoRoute(
            path: 'assignments',
            builder: (context, state) => const AssignmentsScreen(),
          ),
          GoRoute(
            path: 'timetable',
            builder: (context, state) => const TimetableScreen(),
          ),
          GoRoute(
            path: 'exams',
            builder: (context, state) => const ExamsScreen(),
          ),
          GoRoute(
            path: 'report-cards',
            builder: (context, state) => const ReportCardScreen(),
          ),
          GoRoute(
            path: 'messages',
            builder: (context, state) => const MessagesScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/parent',
        builder: (context, state) => const ParentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'children',
            builder: (context, state) => const ChildrenListScreen(),
          ),
          GoRoute(
            path: 'child/:studentId',
            builder: (context, state) {
              final studentId = int.parse(state.pathParameters['studentId']!);
              return ChildDetailScreen(studentId: studentId);
            },
          ),
          GoRoute(
            path: 'messages',
            builder: (context, state) => const MessagesScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboardScreen(),
        routes: [
          GoRoute(
            path: 'class',
            builder: (context, state) => const ClassStudentsScreen(),
          ),
          GoRoute(
            path: 'attendance',
            builder: (context, state) => const MarkAttendanceScreen(),
          ),
          GoRoute(
            path: 'assignments',
            builder: (context, state) => const teacher.TeacherAssignmentsScreen(),
          ),
          GoRoute(
            path: 'messages',
            builder: (context, state) => const MessagesScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );

  static String _getHomeRoute(String? role) {
    switch (role) {
      case 'student':
        return '/student';
      case 'parent':
        return '/parent';
      case 'teacher':
        return '/teacher';
      default:
        return '/login';
    }
  }
}
