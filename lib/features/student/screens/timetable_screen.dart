import 'package:flutter/material.dart';
import '../../../core/models/timetable.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  bool _isLoading = false;
  late Timetable _timetable;
  String _selectedDay = 'monday';

  final List<String> _weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _getCurrentDay();
    _loadTimetable();
  }

  String _getCurrentDay() {
    final day = DateTime.now().weekday;
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return day <= 5 ? days[day - 1] : 'monday';
  }

  Future<void> _loadTimetable() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final entries = [
      TimetableEntry(
        id: 1,
        subject: 'Mathematics',
        teacher: 'Mr. Ahmed Ali',
        room: 'Room 101',
        dayOfWeek: 'monday',
        startTime: '08:00',
        endTime: '09:00',
        periodNumber: 1,
      ),
      TimetableEntry(
        id: 2,
        subject: 'Arabic',
        teacher: 'Mr. Hassan',
        room: 'Room 102',
        dayOfWeek: 'monday',
        startTime: '09:00',
        endTime: '10:00',
        periodNumber: 2,
      ),
      TimetableEntry(
        id: 3,
        subject: 'Science',
        teacher: 'Dr. Sarah',
        room: 'Lab 1',
        dayOfWeek: 'monday',
        startTime: '10:30',
        endTime: '11:30',
        periodNumber: 3,
      ),
      TimetableEntry(
        id: 4,
        subject: 'English',
        teacher: 'Ms. Fatima',
        room: 'Room 103',
        dayOfWeek: 'monday',
        startTime: '11:30',
        endTime: '12:30',
        periodNumber: 4,
      ),
      TimetableEntry(
        id: 5,
        subject: 'Physical Education',
        teacher: 'Mr. Abdullah',
        room: 'Gym',
        dayOfWeek: 'monday',
        startTime: '13:00',
        endTime: '14:00',
        periodNumber: 5,
      ),
      TimetableEntry(
        id: 6,
        subject: 'Science',
        teacher: 'Dr. Sarah',
        room: 'Lab 1',
        dayOfWeek: 'tuesday',
        startTime: '08:00',
        endTime: '09:00',
        periodNumber: 1,
      ),
      TimetableEntry(
        id: 7,
        subject: 'Mathematics',
        teacher: 'Mr. Ahmed Ali',
        room: 'Room 101',
        dayOfWeek: 'tuesday',
        startTime: '09:00',
        endTime: '10:00',
        periodNumber: 2,
      ),
      TimetableEntry(
        id: 8,
        subject: 'History',
        teacher: 'Mr. Mohammed',
        room: 'Room 104',
        dayOfWeek: 'tuesday',
        startTime: '10:30',
        endTime: '11:30',
        periodNumber: 3,
      ),
      TimetableEntry(
        id: 9,
        subject: 'English',
        teacher: 'Ms. Fatima',
        room: 'Room 103',
        dayOfWeek: 'tuesday',
        startTime: '11:30',
        endTime: '12:30',
        periodNumber: 4,
      ),
      TimetableEntry(
        id: 10,
        subject: 'Art',
        teacher: 'Ms. Layla',
        room: 'Art Room',
        dayOfWeek: 'tuesday',
        startTime: '13:00',
        endTime: '14:00',
        periodNumber: 5,
      ),
      TimetableEntry(
        id: 11,
        subject: 'Arabic',
        teacher: 'Mr. Hassan',
        room: 'Room 102',
        dayOfWeek: 'wednesday',
        startTime: '08:00',
        endTime: '09:00',
        periodNumber: 1,
      ),
      TimetableEntry(
        id: 12,
        subject: 'Mathematics',
        teacher: 'Mr. Ahmed Ali',
        room: 'Room 101',
        dayOfWeek: 'wednesday',
        startTime: '09:00',
        endTime: '10:00',
        periodNumber: 2,
      ),
      TimetableEntry(
        id: 13,
        subject: 'Computer Science',
        teacher: 'Mr. Khalid',
        room: 'Computer Lab',
        dayOfWeek: 'wednesday',
        startTime: '10:30',
        endTime: '11:30',
        periodNumber: 3,
      ),
      TimetableEntry(
        id: 14,
        subject: 'Science',
        teacher: 'Dr. Sarah',
        room: 'Lab 1',
        dayOfWeek: 'wednesday',
        startTime: '11:30',
        endTime: '12:30',
        periodNumber: 4,
      ),
      TimetableEntry(
        id: 15,
        subject: 'Islamic Studies',
        teacher: 'Sheikh Omar',
        room: 'Room 105',
        dayOfWeek: 'wednesday',
        startTime: '13:00',
        endTime: '14:00',
        periodNumber: 5,
      ),
      TimetableEntry(
        id: 16,
        subject: 'English',
        teacher: 'Ms. Fatima',
        room: 'Room 103',
        dayOfWeek: 'thursday',
        startTime: '08:00',
        endTime: '09:00',
        periodNumber: 1,
      ),
      TimetableEntry(
        id: 17,
        subject: 'History',
        teacher: 'Mr. Mohammed',
        room: 'Room 104',
        dayOfWeek: 'thursday',
        startTime: '09:00',
        endTime: '10:00',
        periodNumber: 2,
      ),
      TimetableEntry(
        id: 18,
        subject: 'Mathematics',
        teacher: 'Mr. Ahmed Ali',
        room: 'Room 101',
        dayOfWeek: 'thursday',
        startTime: '10:30',
        endTime: '11:30',
        periodNumber: 3,
      ),
      TimetableEntry(
        id: 19,
        subject: 'Arabic',
        teacher: 'Mr. Hassan',
        room: 'Room 102',
        dayOfWeek: 'thursday',
        startTime: '11:30',
        endTime: '12:30',
        periodNumber: 4,
      ),
      TimetableEntry(
        id: 20,
        subject: 'Science',
        teacher: 'Dr. Sarah',
        room: 'Lab 1',
        dayOfWeek: 'thursday',
        startTime: '13:00',
        endTime: '14:00',
        periodNumber: 5,
      ),
    ];

    _timetable = Timetable(entries: entries);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timetable'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDaySelector(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadTimetable,
                    child: _buildTimetableView(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final day = _weekDays[index];
          final isSelected = day == _selectedDay;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _getDayName(day),
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedDay = day);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimetableView() {
    final entries = _timetable.getEntriesForDay(_selectedDay);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No classes scheduled',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrentPeriod = _isCurrentPeriod(entry);
        return _PeriodCard(
          entry: entry,
          isCurrentPeriod: isCurrentPeriod,
        );
      },
    );
  }

  bool _isCurrentPeriod(TimetableEntry entry) {
    if (_selectedDay != _getCurrentDay()) return false;

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return currentTime.compareTo(entry.startTime) >= 0 &&
        currentTime.compareTo(entry.endTime) < 0;
  }

  String _getDayName(String day) {
    final names = {
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
    };
    return names[day] ?? day;
  }
}

class _PeriodCard extends StatelessWidget {
  final TimetableEntry entry;
  final bool isCurrentPeriod;

  const _PeriodCard({
    required this.entry,
    required this.isCurrentPeriod,
  });

  Color _getSubjectColor(String subject) {
    final colors = {
      'Mathematics': Colors.blue,
      'Science': Colors.green,
      'English': Colors.orange,
      'Arabic': Colors.red,
      'History': Colors.brown,
      'Physical Education': Colors.purple,
      'Art': Colors.pink,
      'Computer Science': Colors.teal,
      'Islamic Studies': Colors.indigo,
    };
    return colors[subject] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = _getSubjectColor(entry.subject);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrentPeriod ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentPeriod
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: subjectColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.subject,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: subjectColor,
                              ),
                        ),
                      ),
                      if (isCurrentPeriod)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.teacher,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        entry.room,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        entry.timeRange,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
