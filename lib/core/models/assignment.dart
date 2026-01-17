class Assignment {
  final int id;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  final DateTime? submittedDate;
  final String status;
  final int? teacherId;
  final String? teacherName;
  final String? attachmentUrl;
  final double? score;
  final double? maxScore;
  final String? feedback;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    this.submittedDate,
    required this.status,
    this.teacherId,
    this.teacherName,
    this.attachmentUrl,
    this.score,
    this.maxScore,
    this.feedback,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as int,
      title: json['name'] as String? ?? json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      subject: json['subject_id'] is List
          ? (json['subject_id'] as List)[1] as String
          : json['subject'] as String? ?? 'General',
      dueDate: DateTime.parse(json['due_date'] as String),
      submittedDate: json['submitted_date'] != null
          ? DateTime.parse(json['submitted_date'] as String)
          : null,
      status: json['state'] as String? ?? json['status'] as String? ?? 'pending',
      teacherId: json['teacher_id'] is List
          ? (json['teacher_id'] as List)[0] as int
          : json['teacher_id'] as int?,
      teacherName: json['teacher_id'] is List
          ? (json['teacher_id'] as List)[1] as String
          : json['teacher_name'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      maxScore: json['max_score'] != null ? (json['max_score'] as num).toDouble() : null,
      feedback: json['feedback'] as String?,
    );
  }

  bool get isSubmitted => submittedDate != null;
  bool get isOverdue => DateTime.now().isAfter(dueDate) && !isSubmitted;
  bool get isGraded => score != null;

  String get statusDisplay {
    if (isGraded) return 'Graded';
    if (isSubmitted) return 'Submitted';
    if (isOverdue) return 'Overdue';
    return 'Pending';
  }
}
