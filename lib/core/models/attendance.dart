class Attendance {
  final int id;
  final int studentId;
  final String studentName;
  final DateTime date;
  final String status; // 'present', 'absent', 'late', 'excused'
  final String? checkIn;
  final String? checkOut;
  final String? notes;

  Attendance({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.notes,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int,
      studentId: json['student_id'] != null ? (json['student_id'] as List)[0] as int : 0,
      studentName: json['student_id'] != null ? (json['student_id'] as List)[1] as String : '',
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String? ?? 'absent',
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
