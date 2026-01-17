import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/assignment.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Assignment> _allAssignments = [];
  List<Assignment> _pendingAssignments = [];
  List<Assignment> _submittedAssignments = [];
  List<Assignment> _gradedAssignments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAssignments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    _allAssignments = [
      Assignment(
        id: 1,
        title: 'Mathematics Chapter 5 Exercise',
        description: 'Complete all problems from chapter 5',
        subject: 'Mathematics',
        dueDate: now.add(const Duration(days: 3)),
        status: 'pending',
        teacherName: 'Mr. Ahmed',
        maxScore: 20,
      ),
      Assignment(
        id: 2,
        title: 'Science Lab Report',
        description: 'Write a detailed lab report on the experiment conducted',
        subject: 'Science',
        dueDate: now.add(const Duration(days: 5)),
        status: 'pending',
        teacherName: 'Dr. Sarah',
        maxScore: 25,
      ),
      Assignment(
        id: 3,
        title: 'English Essay',
        description: 'Write a 500-word essay on climate change',
        subject: 'English',
        dueDate: now.subtract(const Duration(days: 1)),
        status: 'pending',
        teacherName: 'Ms. Fatima',
        maxScore: 30,
      ),
      Assignment(
        id: 4,
        title: 'History Project',
        description: 'Research and present on Saudi history',
        subject: 'History',
        dueDate: now.add(const Duration(days: 7)),
        status: 'submitted',
        submittedDate: now.subtract(const Duration(days: 1)),
        teacherName: 'Mr. Mohammed',
        maxScore: 40,
      ),
      Assignment(
        id: 5,
        title: 'Arabic Grammar Exercise',
        description: 'Complete exercises 1-10',
        subject: 'Arabic',
        dueDate: now.subtract(const Duration(days: 5)),
        status: 'submitted',
        submittedDate: now.subtract(const Duration(days: 6)),
        teacherName: 'Mr. Hassan',
        score: 18,
        maxScore: 20,
        feedback: 'Excellent work! Keep it up.',
      ),
    ];

    _pendingAssignments = _allAssignments
        .where((a) => !a.isSubmitted && !a.isGraded)
        .toList();
    _submittedAssignments = _allAssignments
        .where((a) => a.isSubmitted && !a.isGraded)
        .toList();
    _gradedAssignments = _allAssignments
        .where((a) => a.isGraded)
        .toList();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Submitted'),
            Tab(text: 'Graded'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAssignments,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAssignmentList(_allAssignments),
                  _buildAssignmentList(_pendingAssignments),
                  _buildAssignmentList(_submittedAssignments),
                  _buildAssignmentList(_gradedAssignments),
                ],
              ),
            ),
    );
  }

  Widget _buildAssignmentList(List<Assignment> assignments) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No assignments found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _AssignmentCard(
          assignment: assignment,
          onTap: () => _showAssignmentDetails(assignment),
        );
      },
    );
  }

  void _showAssignmentDetails(Assignment assignment) {
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
                      assignment.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  _StatusChip(assignment: assignment),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.book,
                label: 'Subject',
                value: assignment.subject,
              ),
              _DetailRow(
                icon: Icons.person,
                label: 'Teacher',
                value: assignment.teacherName ?? 'N/A',
              ),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Due Date',
                value: DateFormat('MMM dd, yyyy').format(assignment.dueDate),
                valueColor: assignment.isOverdue ? Colors.red : null,
              ),
              if (assignment.submittedDate != null)
                _DetailRow(
                  icon: Icons.check_circle,
                  label: 'Submitted',
                  value: DateFormat('MMM dd, yyyy').format(assignment.submittedDate!),
                  valueColor: Colors.green,
                ),
              if (assignment.score != null)
                _DetailRow(
                  icon: Icons.grade,
                  label: 'Score',
                  value: '${assignment.score}/${assignment.maxScore}',
                  valueColor: Colors.blue,
                ),
              const Divider(height: 32),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(assignment.description),
              if (assignment.feedback != null) ...[
                const Divider(height: 32),
                Text(
                  'Teacher Feedback',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(assignment.feedback!),
                ),
              ],
              const SizedBox(height: 24),
              if (!assignment.isSubmitted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitAssignment(assignment);
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Submit Assignment'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAssignment(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Assignment'),
        content: const Text('This will submit your assignment. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignment submitted successfully')),
              );
              _loadAssignments();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onTap;

  const _AssignmentCard({
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    child: Text(
                      assignment.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _StatusChip(assignment: assignment),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.book, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    assignment.subject,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd').format(assignment.dueDate),
                    style: TextStyle(
                      color: assignment.isOverdue ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (assignment.score != null) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: assignment.score! / assignment.maxScore!,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    assignment.score! / assignment.maxScore! >= 0.7
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${assignment.score}/${assignment.maxScore}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Assignment assignment;

  const _StatusChip({required this.assignment});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (assignment.isGraded) {
      color = Colors.blue;
    } else if (assignment.isSubmitted) {
      color = Colors.green;
    } else if (assignment.isOverdue) {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        assignment.statusDisplay,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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
