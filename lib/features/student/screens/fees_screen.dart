import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/models/fee.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final fees = provider.fees;

          if (fees.isEmpty) {
            return const Center(child: Text('No fee records found'));
          }

          // Calculate totals
          final totalDue = fees
              .where((f) => f.state == 'open' || f.state == 'partial')
              .map((f) => f.amountDue)
              .fold(0.0, (a, b) => a + b);

          return Column(
            children: [
              // Summary Card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total Amount Due',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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

              // Fees List
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${DateFormat('MMM dd, yyyy').format(fee.invoiceDate)}'),
                            if (fee.dueDate != null)
                              Text('Due: ${DateFormat('MMM dd, yyyy').format(fee.dueDate!)}'),
                            Text('Amount: SAR ${fee.amountTotal.toStringAsFixed(2)}'),
                            if (fee.amountDue > 0)
                              Text(
                                'Due: SAR ${fee.amountDue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: fee.isOverdue ? Colors.red : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Chip(
                              label: Text(fee.state.toUpperCase()),
                              backgroundColor: _getStateColor(fee.state),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            if (fee.isOverdue)
                              const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'open':
      case 'partial':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStateIcon(String state) {
    switch (state.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'open':
      case 'partial':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
