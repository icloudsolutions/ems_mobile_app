class Student {
  final int id;
  final String name;
  final String studentNumber;
  final int? gradeId;
  final String? gradeName;
  final int? divisionId;
  final String? divisionName;
  final int? schoolId;
  final String? schoolName;
  final String? dateOfBirth;
  final String? gender;
  final String? nationalId;
  final String? imageUrl;
  final String? state;

  Student({
    required this.id,
    required this.name,
    required this.studentNumber,
    this.gradeId,
    this.gradeName,
    this.divisionId,
    this.divisionName,
    this.schoolId,
    this.schoolName,
    this.dateOfBirth,
    this.gender,
    this.nationalId,
    this.imageUrl,
    this.state,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      studentNumber: json['student_number'] as String? ?? '',
      gradeId: json['grade_id'] != null ? (json['grade_id'] as List)[0] as int? : null,
      gradeName: json['grade_id'] != null ? (json['grade_id'] as List)[1] as String? : null,
      divisionId: json['division_id'] != null ? (json['division_id'] as List)[0] as int? : null,
      divisionName: json['division_id'] != null ? (json['division_id'] as List)[1] as String? : null,
      schoolId: json['school_id'] != null ? (json['school_id'] as List)[0] as int? : null,
      schoolName: json['school_id'] != null ? (json['school_id'] as List)[1] as String? : null,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      nationalId: json['national_id'] as String?,
      imageUrl: json['image_1920'] as String?,
      state: json['state'] as String?,
    );
  }
}
