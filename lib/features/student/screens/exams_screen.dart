import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/exam.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Exam> _allExams = [];
  List<Exam> _upcomingExams = [];
  List<Exam> _completedExams = [];
  List<Exam> _gradedExams = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadExams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    _allExams = [
      Exam(
        id: 1,
        name: 'Midterm Exam',
        subject: 'Mathematics',
        date: now.add(const Duration(days: 5)),
        time: '09:00',
        room: 'Hall A',
        duration: 120,
        totalMarks: 100,
        status: 'scheduled',
        syllabus: 'Chapters 1-5',
      ),
      Exam(
        id: 2,
        name: 'Unit Test',
        subject: 'Science',
        date: now.add(const Duration(days: 10)),
        time: '10:00',
        room: 'Lab 1',
        duration: 90,
        totalMarks: 50,
        status: 'scheduled',
        syllabus: 'Physics: Motion and Forces',
      ),
      Exam(
        id: 3,
        name: 'Final Exam',
        subject: 'English',
        date: now.add(const Duration(days: 15)),
        time: '08:30',
        room: 'Hall B',
        duration: 180,
        totalMarks: 100,
        status: 'scheduled',
        syllabus: 'Full syllabus',
      ),
      Exam(
        id: 4,
        name: 'Monthly Test',
        subject: 'Arabic',
        date: now.subtract(const Duration(days: 10)),
        time: '09:00',
        room: 'Room 102',
        duration: 60,
        totalMarks: 50,
        obtainedMarks: 42,
        grade: 'A',
        status: 'completed',
      ),
      Exam(
        id: 5,
        name: 'Midterm Exam',
        subject: 'History',
        date: now.subtract(const Duration(days: 15)),
        time: '10:00',
        room: 'Room 104',
        duration: 90,
        totalMarks: 75,
        obtainedMarks: 68,
        grade: 'B+',
        status: 'completed',
      ),
      Exam(
        id: 6,
        name: 'Final Exam',
        subject: 'Science',
        date: now.subtract(const Duration(days: 20)),
        time: '09:00',
        room: 'Lab 1',
        duration: 120,
        totalMarks: 100,
        obtainedMarks: 88,
        grade: 'A',
        status: 'completed',
      ),
    ];

    _upcomingExams = _allExams.where((e) => e.isUpcoming).toList();
    _completedExams = _allExams.where((e) => e.isCompleted && !e.isGraded).toList();
    _gradedExams = _allExams.where((e) => e.isGraded).toList();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Results'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExams,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExamList(_upcomingExams, isUpcoming: true),
                  _buildExamList(_completedExams),
                  _buildResultsList(_gradedExams),
                ],
              ),
            ),
    );
  }

  Widget _buildExamList(List<Exam> exams, {bool isUpcoming = false}) {
    if (exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming exams' : 'No completed exams',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return _ExamCard(
          exam: exam,
          onTap: () => _showExamDetails(exam),
        );
      },
    );
  }

  Widget _buildResultsList(List<Exam> exams) {
    if (exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return _ResultCard(
          exam: exam,
          onTap: () => _showExamDetails(exam),
        );
      },
    );
  }

  void _showExamDetails(Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exam.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (exam.isGraded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getGradeColor(exam.grade!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        exam.grade!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.book,
                label: 'Subject',
                value: exam.subject,
              ),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: DateFormat('MMM dd, yyyy').format(exam.date),
              ),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Time',
                value: exam.time,
              ),
              _DetailRow(
                icon: Icons.location_on,
                label: 'Room',
                value: exam.room,
              ),
              _DetailRow(
                icon: Icons.timer,
                label: 'Duration',
                value: '${exam.duration} minutes',
              ),
              if (exam.isGraded) ...[
                const Divider(height: 32),
                _DetailRow(
                  icon: Icons.grade,
                  label: 'Score',
                  value: '${exam.obtainedMarks}/${exam.totalMarks}',
                  valueColor: Colors.blue,
                ),
                _DetailRow(
                  icon: Icons.percent,
                  label: 'Percentage',
                  value: '${exam.percentage!.toStringAsFixed(1)}%',
                  valueColor: Colors.blue,
                ),
              ],
              if (exam.syllabus != null) ...[
                const Divider(height: 32),
                Text(
                  'Syllabus',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(exam.syllabus!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.red;
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onTap;

  const _ExamCard({
    required this.exam,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil = exam.date.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exam.subject,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (daysUntil <= 7)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: daysUntil <= 3 ? Colors.red[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        daysUntil == 0
                            ? 'Today'
                            : daysUntil == 1
                                ? 'Tomorrow'
                                : '$daysUntil days',
                        style: TextStyle(
                          color: daysUntil <= 3 ? Colors.red[700] : Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(exam.date),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    exam.time,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    exam.room,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onTap;

  const _ResultCard({
    required this.exam,
    required this.onTap,
  });

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor(exam.grade!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gradeColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    exam.grade!,
                    style: TextStyle(
                      color: gradeColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exam.subject,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${exam.obtainedMarks}/${exam.totalMarks}',
                          style: TextStyle(
                            color: gradeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${exam.percentage!.toStringAsFixed(1)}%)',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
