import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';

class TeacherProvider with ChangeNotifier {
  final ApiService apiService;
  
  List<Student> _students = [];
  Map<int, List<Attendance>> _attendanceByStudent = {};
  bool _isLoading = false;
  String? _error;

  TeacherProvider({required this.apiService});

  List<Student> get students => _students;
  Map<int, List<Attendance>> get attendanceByStudent => _attendanceByStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStudents(int teacherId, {int? gradeId, int? divisionId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final domain = <List<dynamic>>[];
      if (gradeId != null) {
        domain.add(['grade_id', '=', gradeId]);
      }
      if (divisionId != null) {
        domain.add(['division_id', '=', divisionId]);
      }

      final result = await apiService.searchRead(
        'ics.student',
        domain: domain,
        fields: [
          'id', 'name', 'student_number', 'grade_id', 'division_id', 
          'school_id', 'date_of_birth', 'gender', 'national_id', 'image_1920', 'state'
        ],
        order: 'name',
      );

      _students = (result as List).map((json) => Student.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceForClass({int? gradeId, int? divisionId, DateTime? date}) async {
    try {
      final domain = <List<dynamic>>[];
      if (gradeId != null) {
        domain.add(['student_id.grade_id', '=', gradeId]);
      }
      if (divisionId != null) {
        domain.add(['student_id.division_id', '=', divisionId]);
      }
      if (date != null) {
        domain.add(['date', '=', date.toIso8601String().split('T')[0]]);
      }

      final result = await apiService.searchRead(
        'ics.student.attendance',
        domain: domain,
        fields: ['id', 'student_id', 'date', 'status', 'check_in', 'check_out', 'notes'],
        order: 'student_id, date desc',
      );

      final attendanceList = (result as List).map((json) => Attendance.fromJson(json)).toList();
      
      _attendanceByStudent.clear();
      for (var attendance in attendanceList) {
        if (!_attendanceByStudent.containsKey(attendance.studentId)) {
          _attendanceByStudent[attendance.studentId] = [];
        }
        _attendanceByStudent[attendance.studentId]!.add(attendance);
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> markAttendance(int studentId, DateTime date, String status, {String? notes}) async {
    try {
      // Check if attendance already exists
      final existing = await apiService.searchRead(
        'ics.student.attendance',
        domain: [
          ['student_id', '=', studentId],
          ['date', '=', date.toIso8601String().split('T')[0]],
        ],
      );

      if (existing.isNotEmpty) {
        // Update existing
        await apiService.write('ics.student.attendance', [existing[0]['id'] as int], {
          'status': status,
          'notes': notes,
        });
      } else {
        // Create new
        await apiService.create('ics.student.attendance', {
          'student_id': studentId,
          'date': date.toIso8601String().split('T')[0],
          'status': status,
          'notes': notes,
        });
      }

      await loadAttendanceForClass();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
