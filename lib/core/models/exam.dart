class Exam {
  final int id;
  final String name;
  final String subject;
  final DateTime date;
  final String time;
  final String room;
  final int duration;
  final double? totalMarks;
  final double? obtainedMarks;
  final String? grade;
  final String status;
  final String? syllabus;

  Exam({
    required this.id,
    required this.name,
    required this.subject,
    required this.date,
    required this.time,
    required this.room,
    required this.duration,
    this.totalMarks,
    this.obtainedMarks,
    this.grade,
    required this.status,
    this.syllabus,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Exam',
      subject: json['subject_id'] is List
          ? (json['subject_id'] as List)[1] as String
          : json['subject'] as String? ?? 'Subject',
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String? ?? json['start_time'] as String? ?? '09:00',
      room: json['room'] as String? ?? json['room_id'] is List
          ? (json['room_id'] as List)[1] as String
          : 'TBA',
      duration: json['duration'] as int? ?? 60,
      totalMarks: json['total_marks'] != null
          ? (json['total_marks'] as num).toDouble()
          : null,
      obtainedMarks: json['obtained_marks'] != null
          ? (json['obtained_marks'] as num).toDouble()
          : null,
      grade: json['grade'] as String?,
      status: json['status'] as String? ?? json['state'] as String? ?? 'scheduled',
      syllabus: json['syllabus'] as String?,
    );
  }

  bool get isUpcoming => DateTime.now().isBefore(date);
  bool get isCompleted => status == 'completed' || obtainedMarks != null;
  bool get isGraded => obtainedMarks != null;

  double? get percentage {
    if (obtainedMarks != null && totalMarks != null && totalMarks! > 0) {
      return (obtainedMarks! / totalMarks!) * 100;
    }
    return null;
  }

  String get statusDisplay {
    if (isGraded) return 'Graded';
    if (isCompleted) return 'Completed';
    if (isUpcoming) return 'Upcoming';
    return 'In Progress';
  }
}
