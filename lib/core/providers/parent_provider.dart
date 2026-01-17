import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/fee.dart';
import '../services/api_service.dart';

class ParentProvider with ChangeNotifier {
  final ApiService apiService;
  
  List<Student> _children = [];
  Map<int, List<Attendance>> _attendanceByStudent = {};
  Map<int, List<FeeInvoice>> _feesByStudent = {};
  bool _isLoading = false;
  String? _error;

  ParentProvider({required this.apiService});

  List<Student> get children => _children;
  Map<int, List<Attendance>> get attendanceByStudent => _attendanceByStudent;
  Map<int, List<FeeInvoice>> get feesByStudent => _feesByStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChildren(int parentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parentResult = await apiService.read('ics.parent', [parentId], fields: ['student_ids']);
      if (parentResult.isNotEmpty) {
        final studentIds = (parentResult[0]['student_ids'] as List<dynamic>).cast<int>();
        
        if (studentIds.isNotEmpty) {
          final studentsResult = await apiService.read('ics.student', studentIds, fields: [
            'id', 'name', 'student_number', 'grade_id', 'division_id', 
            'school_id', 'date_of_birth', 'gender', 'national_id', 'image_1920', 'state'
          ]);
          
          _children = (studentsResult as List).map((json) => Student.fromJson(json)).toList();
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceForStudent(int studentId) async {
    try {
      final result = await apiService.searchRead(
        'ics.student.attendance',
        domain: [['student_id', '=', studentId]],
        fields: ['id', 'student_id', 'date', 'status', 'check_in', 'check_out', 'notes'],
        order: 'date desc',
        limit: 30,
      );

      _attendanceByStudent[studentId] = 
          (result as List).map((json) => Attendance.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadFeesForStudent(int studentId) async {
    try {
      final result = await apiService.searchRead(
        'ics.fee.invoice',
        domain: [['student_id', '=', studentId]],
        fields: [
          'id', 'name', 'student_id', 'invoice_date', 'due_date',
          'amount_total', 'amount_paid', 'amount_due', 'state', 'is_overdue', 'currency_id'
        ],
        order: 'invoice_date desc',
      );

      _feesByStudent[studentId] = 
          (result as List).map((json) => FeeInvoice.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
