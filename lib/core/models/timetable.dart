class TimetableEntry {
  final int id;
  final String subject;
  final String teacher;
  final String room;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int periodNumber;

  TimetableEntry({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.periodNumber,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'] as int,
      subject: json['subject_id'] is List
          ? (json['subject_id'] as List)[1] as String
          : json['subject'] as String? ?? 'Subject',
      teacher: json['teacher_id'] is List
          ? (json['teacher_id'] as List)[1] as String
          : json['teacher'] as String? ?? 'Teacher',
      room: json['room'] as String? ?? json['room_id'] is List
          ? (json['room_id'] as List)[1] as String
          : 'Room',
      dayOfWeek: json['day_of_week'] as String? ?? 'monday',
      startTime: json['start_time'] as String? ?? '08:00',
      endTime: json['end_time'] as String? ?? '09:00',
      periodNumber: json['period_number'] as int? ?? 1,
    );
  }

  String get dayDisplay {
    final days = {
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
    };
    return days[dayOfWeek.toLowerCase()] ?? dayOfWeek;
  }

  String get timeRange => '$startTime - $endTime';
}

class Timetable {
  final List<TimetableEntry> entries;

  Timetable({required this.entries});

  Map<String, List<TimetableEntry>> get byDay {
    final Map<String, List<TimetableEntry>> grouped = {};
    for (var entry in entries) {
      if (!grouped.containsKey(entry.dayOfWeek)) {
        grouped[entry.dayOfWeek] = [];
      }
      grouped[entry.dayOfWeek]!.add(entry);
    }
    for (var day in grouped.keys) {
      grouped[day]!.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
    }
    return grouped;
  }

  List<TimetableEntry> getEntriesForDay(String day) {
    return entries.where((e) => e.dayOfWeek.toLowerCase() == day.toLowerCase()).toList()
      ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
  }
}
