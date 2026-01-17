import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/grade.dart';
import '../models/fee.dart';
import '../services/api_service.dart';

class StudentProvider with ChangeNotifier {
  final ApiService apiService;
  
  Student? _student;
  List<Attendance> _attendance = [];
  List<Grade> _grades = [];
  List<FeeInvoice> _fees = [];
  bool _isLoading = false;
  String? _error;

  StudentProvider({required this.apiService});

  Student? get student => _student;
  List<Attendance> get attendance => _attendance;
  List<Grade> get grades => _grades;
  List<FeeInvoice> get fees => _fees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStudentProfile(int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await apiService.read('ics.student', [studentId], fields: [
        'id', 'name', 'student_number', 'grade_id', 'division_id', 
        'school_id', 'date_of_birth', 'gender', 'national_id', 'image_1920', 'state'
      ]);
      
      if (result.isNotEmpty) {
        _student = Student.fromJson(result[0]);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendance(int studentId, {DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final domain = [['student_id', '=', studentId]];
      if (startDate != null) {
        domain.add(['date', '>=', startDate.toIso8601String().split('T')[0]]);
      }
      if (endDate != null) {
        domain.add(['date', '<=', endDate.toIso8601String().split('T')[0]]);
      }

      final result = await apiService.searchRead(
        'ics.student.attendance',
        domain: domain,
        fields: ['id', 'student_id', 'date', 'status', 'check_in', 'check_out', 'notes'],
        order: 'date desc',
      );

      _attendance = (result as List).map((json) => Attendance.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGrades(int studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await apiService.searchRead(
        'ics.student.grade',
        domain: [['student_id', '=', studentId]],
        fields: ['id', 'name', 'code', 'grade_value', 'subject_id', 'exam_date', 'exam_type', 'notes'],
        order: 'exam_date desc',
      );

      _grades = (result as List).map((json) => Grade.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFees(int studentId) async {
    _isLoading = true;
    notifyListeners();

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

      _fees = (result as List).map((json) => FeeInvoice.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
