import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/teacher_provider.dart';

class ClassStudentsScreen extends StatelessWidget {
  const ClassStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Class'),
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, _) {
          final students = provider.students;

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (students.isEmpty) {
            return const Center(
              child: Text('No students assigned'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: student.imageUrl != null
                        ? NetworkImage(student.imageUrl!)
                        : null,
                    child: student.imageUrl == null
                        ? Text(
                            student.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(student.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student #${student.studentNumber}'),
                      if (student.gradeName != null || student.divisionName != null)
                        Text(
                          '${student.gradeName ?? ""} - ${student.divisionName ?? ""}',
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to student detail
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
