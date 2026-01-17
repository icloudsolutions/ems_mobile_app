import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/report_card.dart';

class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({super.key});

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> {
  bool _isLoading = false;
  List<ReportCard> _reportCards = [];

  @override
  void initState() {
    super.initState();
    _loadReportCards();
  }

  Future<void> _loadReportCards() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    _reportCards = [
      ReportCard(
        id: 1,
        term: 'First Term',
        academicYear: '2024-2025',
        date: DateTime.now().subtract(const Duration(days: 30)),
        studentId: 201,
        studentName: 'Student Name',
        grades: [
          SubjectGrade(
            subject: 'Mathematics',
            marks: 88,
            totalMarks: 100,
            grade: 'A',
            teacherName: 'Mr. Ahmed Ali',
            remarks: 'Excellent performance',
          ),
          SubjectGrade(
            subject: 'Science',
            marks: 92,
            totalMarks: 100,
            grade: 'A+',
            teacherName: 'Dr. Sarah',
            remarks: 'Outstanding',
          ),
          SubjectGrade(
            subject: 'English',
            marks: 85,
            totalMarks: 100,
            grade: 'A',
            teacherName: 'Ms. Fatima',
            remarks: 'Very good',
          ),
          SubjectGrade(
            subject: 'Arabic',
            marks: 78,
            totalMarks: 100,
            grade: 'B+',
            teacherName: 'Mr. Hassan',
            remarks: 'Good progress',
          ),
          SubjectGrade(
            subject: 'History',
            marks: 82,
            totalMarks: 100,
            grade: 'A-',
            teacherName: 'Mr. Mohammed',
            remarks: 'Well done',
          ),
        ],
        overallPercentage: 85.0,
        overallGrade: 'A',
        teacherComments: 'An excellent student who consistently demonstrates strong academic performance and good behavior.',
        principalComments: 'Keep up the great work!',
        rank: 3,
        totalStudents: 30,
      ),
      ReportCard(
        id: 2,
        term: 'Second Term',
        academicYear: '2023-2024',
        date: DateTime.now().subtract(const Duration(days: 180)),
        studentId: 201,
        studentName: 'Student Name',
        grades: [
          SubjectGrade(
            subject: 'Mathematics',
            marks: 82,
            totalMarks: 100,
            grade: 'A-',
            teacherName: 'Mr. Ahmed Ali',
          ),
          SubjectGrade(
            subject: 'Science',
            marks: 88,
            totalMarks: 100,
            grade: 'A',
            teacherName: 'Dr. Sarah',
          ),
          SubjectGrade(
            subject: 'English',
            marks: 80,
            totalMarks: 100,
            grade: 'B+',
            teacherName: 'Ms. Fatima',
          ),
          SubjectGrade(
            subject: 'Arabic',
            marks: 75,
            totalMarks: 100,
            grade: 'B',
            teacherName: 'Mr. Hassan',
          ),
          SubjectGrade(
            subject: 'History',
            marks: 78,
            totalMarks: 100,
            grade: 'B+',
            teacherName: 'Mr. Mohammed',
          ),
        ],
        overallPercentage: 80.6,
        overallGrade: 'B+',
        teacherComments: 'Good performance overall. Needs to focus more on Mathematics.',
        principalComments: 'Good work, keep improving!',
        rank: 5,
        totalStudents: 30,
      ),
    ];

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Cards'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReportCards,
              child: _reportCards.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reportCards.length,
                      itemBuilder: (context, index) {
                        final reportCard = _reportCards[index];
                        return _ReportCardItem(
                          reportCard: reportCard,
                          onTap: () => _viewReportCard(reportCard),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No report cards available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  void _viewReportCard(ReportCard reportCard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ReportCardDetailScreen(reportCard: reportCard),
      ),
    );
  }
}

class _ReportCardItem extends StatelessWidget {
  final ReportCard reportCard;
  final VoidCallback onTap;

  const _ReportCardItem({
    required this.reportCard,
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
    final gradeColor = _getGradeColor(reportCard.overallGrade);

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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gradeColor, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      reportCard.overallGrade,
                      style: TextStyle(
                        color: gradeColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${reportCard.overallPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: gradeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reportCard.term,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reportCard.academicYear,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(reportCard.date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.emoji_events, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Rank: ${reportCard.rankDisplay}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
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

class _ReportCardDetailScreen extends StatelessWidget {
  final ReportCard reportCard;

  const _ReportCardDetailScreen({required this.reportCard});

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${reportCard.term} Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading report card...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reportCard.term,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              reportCard.academicYear,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getGradeColor(reportCard.overallGrade).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getGradeColor(reportCard.overallGrade),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                reportCard.overallGrade,
                                style: TextStyle(
                                  color: _getGradeColor(reportCard.overallGrade),
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${reportCard.overallPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: _getGradeColor(reportCard.overallGrade),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.emoji_events,
                          label: 'Rank',
                          value: reportCard.rankDisplay,
                        ),
                        _StatItem(
                          icon: Icons.people,
                          label: 'Class Size',
                          value: reportCard.totalStudents.toString(),
                        ),
                        _StatItem(
                          icon: Icons.book,
                          label: 'Subjects',
                          value: reportCard.grades.length.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Subject Grades',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...reportCard.grades.map((grade) => _SubjectGradeCard(grade: grade)),
            if (reportCard.teacherComments != null) ...[
              const SizedBox(height: 16),
              Text(
                'Teacher Comments',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.comment, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(reportCard.teacherComments!),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (reportCard.principalComments != null) ...[
              const SizedBox(height: 12),
              Text(
                'Principal Comments',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.school, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(reportCard.principalComments!),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubjectGradeCard extends StatelessWidget {
  final SubjectGrade grade;

  const _SubjectGradeCard({required this.grade});

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor(grade.grade);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    grade.subject,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: gradeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gradeColor),
                  ),
                  child: Text(
                    grade.grade,
                    style: TextStyle(
                      color: gradeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marks',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${grade.marks}/${grade.totalMarks}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Percentage',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${grade.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: grade.percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
            ),
            if (grade.teacherName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Teacher: ${grade.teacherName}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
            if (grade.remarks != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  grade.remarks!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
