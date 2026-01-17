import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/student_provider.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          final student = provider.student;

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (student == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: student.imageUrl != null
                      ? NetworkImage(student.imageUrl!)
                      : null,
                  child: student.imageUrl == null
                      ? Text(
                          student.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 48, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  student.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Student #${student.studentNumber}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),

                // Profile Details
                Card(
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.school,
                        label: 'Grade',
                        value: student.gradeName ?? 'N/A',
                      ),
                      const Divider(),
                      _ProfileTile(
                        icon: Icons.class_,
                        label: 'Division',
                        value: student.divisionName ?? 'N/A',
                      ),
                      const Divider(),
                      _ProfileTile(
                        icon: Icons.location_city,
                        label: 'School',
                        value: student.schoolName ?? 'N/A',
                      ),
                      const Divider(),
                      _ProfileTile(
                        icon: Icons.cake,
                        label: 'Date of Birth',
                        value: student.dateOfBirth ?? 'N/A',
                      ),
                      const Divider(),
                      _ProfileTile(
                        icon: Icons.person,
                        label: 'Gender',
                        value: student.gender?.toUpperCase() ?? 'N/A',
                      ),
                      const Divider(),
                      _ProfileTile(
                        icon: Icons.badge,
                        label: 'National ID',
                        value: student.nationalId ?? 'N/A',
                      ),
                      const Divider(),
                      _ProfileTile(
                        icon: Icons.info,
                        label: 'Status',
                        value: student.state?.toUpperCase() ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
