import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/providers/teacher_provider.dart';
import '../../../core/models/student.dart';
import '../../../core/models/attendance.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TeacherProvider>(context, listen: false);
      provider.loadAttendanceForClass(date: _selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
                final provider = Provider.of<TeacherProvider>(context, listen: false);
                provider.loadAttendanceForClass(date: selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),

          // Students List
          Expanded(
            child: Consumer<TeacherProvider>(
              builder: (context, provider, _) {
                final students = provider.students;
                final attendanceByStudent = provider.attendanceByStudent;

                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (students.isEmpty) {
                  return const Center(child: Text('No students assigned'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    Attendance? attendanceRecord;
                    try {
                      attendanceRecord = attendanceByStudent[student.id]
                          ?.firstWhere(
                            (a) => isSameDay(a.date, _selectedDate),
                          );
                    } catch (e) {
                      attendanceRecord = null;
                    }
                    final status = attendanceRecord?.status ?? 'not_marked';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            student.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(student.name),
                        subtitle: Text('Student #${student.studentNumber}'),
                        trailing: DropdownButton<String>(
                          value: status,
                          items: const [
                            DropdownMenuItem(
                              value: 'not_marked',
                              child: Text('Not Marked'),
                            ),
                            DropdownMenuItem(
                              value: 'present',
                              child: Text('Present'),
                            ),
                            DropdownMenuItem(
                              value: 'absent',
                              child: Text('Absent'),
                            ),
                            DropdownMenuItem(
                              value: 'late',
                              child: Text('Late'),
                            ),
                            DropdownMenuItem(
                              value: 'excused',
                              child: Text('Excused'),
                            ),
                          ],
                          onChanged: (newStatus) {
                            if (newStatus != null && newStatus != 'not_marked') {
                              provider.markAttendance(
                                student.id,
                                _selectedDate,
                                newStatus,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
