class Grade {
  final int id;
  final String name;
  final String? code;
  final double? gradeValue;
  final String? subjectName;
  final DateTime? examDate;
  final String? examType;
  final String? notes;

  Grade({
    required this.id,
    required this.name,
    this.code,
    this.gradeValue,
    this.subjectName,
    this.examDate,
    this.examType,
    this.notes,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      gradeValue: (json['grade_value'] as num?)?.toDouble(),
      subjectName: json['subject_id'] != null ? (json['subject_id'] as List)[1] as String? : null,
      examDate: json['exam_date'] != null ? DateTime.parse(json['exam_date'] as String) : null,
      examType: json['exam_type'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
