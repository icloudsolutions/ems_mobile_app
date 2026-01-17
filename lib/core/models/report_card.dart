class ReportCard {
  final int id;
  final String term;
  final String academicYear;
  final DateTime date;
  final int studentId;
  final String studentName;
  final List<SubjectGrade> grades;
  final double overallPercentage;
  final String overallGrade;
  final String? teacherComments;
  final String? principalComments;
  final int rank;
  final int totalStudents;

  ReportCard({
    required this.id,
    required this.term,
    required this.academicYear,
    required this.date,
    required this.studentId,
    required this.studentName,
    required this.grades,
    required this.overallPercentage,
    required this.overallGrade,
    this.teacherComments,
    this.principalComments,
    required this.rank,
    required this.totalStudents,
  });

  factory ReportCard.fromJson(Map<String, dynamic> json) {
    final gradesList = json['grades'] as List<dynamic>? ?? [];
    final grades = gradesList.map((g) => SubjectGrade.fromJson(g as Map<String, dynamic>)).toList();

    return ReportCard(
      id: json['id'] as int,
      term: json['term'] as String? ?? json['semester'] as String? ?? 'Term 1',
      academicYear: json['academic_year'] as String? ?? DateTime.now().year.toString(),
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      studentId: json['student_id'] is List
          ? (json['student_id'] as List)[0] as int
          : json['student_id'] as int,
      studentName: json['student_id'] is List
          ? (json['student_id'] as List)[1] as String
          : json['student_name'] as String? ?? 'Student',
      grades: grades,
      overallPercentage: json['overall_percentage'] != null
          ? (json['overall_percentage'] as num).toDouble()
          : 0.0,
      overallGrade: json['overall_grade'] as String? ?? 'N/A',
      teacherComments: json['teacher_comments'] as String?,
      principalComments: json['principal_comments'] as String?,
      rank: json['rank'] as int? ?? 0,
      totalStudents: json['total_students'] as int? ?? 0,
    );
  }

  String get rankDisplay => '$rank/$totalStudents';
}

class SubjectGrade {
  final String subject;
  final double marks;
  final double totalMarks;
  final String grade;
  final String? teacherName;
  final String? remarks;

  SubjectGrade({
    required this.subject,
    required this.marks,
    required this.totalMarks,
    required this.grade,
    this.teacherName,
    this.remarks,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    return SubjectGrade(
      subject: json['subject_id'] is List
          ? (json['subject_id'] as List)[1] as String
          : json['subject'] as String? ?? 'Subject',
      marks: (json['marks'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (json['total_marks'] as num?)?.toDouble() ?? 100.0,
      grade: json['grade'] as String? ?? 'N/A',
      teacherName: json['teacher_id'] is List
          ? (json['teacher_id'] as List)[1] as String
          : json['teacher_name'] as String?,
      remarks: json['remarks'] as String?,
    );
  }

  double get percentage => totalMarks > 0 ? (marks / totalMarks) * 100 : 0.0;
}
