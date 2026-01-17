import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/parent_provider.dart';
import '../../../core/models/student.dart';
import '../../../core/models/attendance.dart';
import '../../../core/models/fee.dart';
import 'package:intl/intl.dart';

class ChildDetailScreen extends StatefulWidget {
  final int studentId;

  const ChildDetailScreen({super.key, required this.studentId});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Student? _student;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ParentProvider>(context, listen: false);
    await provider.loadAttendanceForStudent(widget.studentId);
    await provider.loadFeesForStudent(widget.studentId);
    
    // Find student from children list
    final children = provider.children;
    _student = children.firstWhere(
      (s) => s.id == widget.studentId,
      orElse: () => Student(
        id: widget.studentId,
        name: 'Unknown',
        studentNumber: '',
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student?.name ?? 'Child Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.event_available), text: 'Attendance'),
            Tab(icon: Icon(Icons.payment), text: 'Fees'),
            Tab(icon: Icon(Icons.grade), text: 'Grades'),
          ],
        ),
      ),
      body: Consumer<ParentProvider>(
        builder: (context, provider, _) {
          final attendance = provider.attendanceByStudent[widget.studentId] ?? [];
          final fees = provider.feesByStudent[widget.studentId] ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _AttendanceTab(attendance: attendance),
              _FeesTab(fees: fees),
              _GradesTab(),
            ],
          );
        },
      ),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  final List<Attendance> attendance;

  const _AttendanceTab({required this.attendance});

  @override
  Widget build(BuildContext context) {
    if (attendance.isEmpty) {
      return const Center(child: Text('No attendance records'));
    }

    final present = attendance.where((a) => a.status == 'present').length;
    final total = attendance.length;
    final percentage = total > 0 ? (present / total * 100).toStringAsFixed(1) : '0.0';

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text('Attendance Rate'),
                  ],
                ),
                const VerticalDivider(),
                Column(
                  children: [
                    Text(
                      '$present/$total',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text('Present Days'),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: attendance.length,
            itemBuilder: (context, index) {
              final record = attendance[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(record.status),
                    child: Icon(
                      _getStatusIcon(record.status),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(DateFormat('EEEE, MMM dd, yyyy').format(record.date)),
                  subtitle: Text('Status: ${record.status.toUpperCase()}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }
}

class _FeesTab extends StatelessWidget {
  final List<FeeInvoice> fees;

  const _FeesTab({required this.fees});

  @override
  Widget build(BuildContext context) {
    if (fees.isEmpty) {
      return const Center(child: Text('No fee records'));
    }

    final totalDue = fees
        .where((f) => f.state == 'open' || f.state == 'partial')
        .map((f) => f.amountDue)
        .fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Total Amount Due'),
                const SizedBox(height: 8),
                Text(
                  'SAR ${totalDue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: fees.length,
            itemBuilder: (context, index) {
              final fee = fees[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStateColor(fee.state),
                    child: Icon(
                      _getStateIcon(fee.state),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(fee.name),
                  subtitle: Text(
                    'Due: SAR ${fee.amountDue.toStringAsFixed(2)}',
                  ),
                  trailing: Chip(
                    label: Text(fee.state.toUpperCase()),
                    backgroundColor: _getStateColor(fee.state),
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'open':
      case 'partial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStateIcon(String state) {
    switch (state.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'open':
      case 'partial':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }
}

class _GradesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Grades feature coming soon'),
    );
  }
}
