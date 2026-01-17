import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiKeyController;
  late TextEditingController _appIdController;
  late TextEditingController _senderIdController;
  late TextEditingController _projectIdController;
  late TextEditingController _storageBucketController;
  late TextEditingController _authDomainController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final settings = provider.settings;
    
    _apiKeyController = TextEditingController(text: settings.firebaseApiKey ?? '');
    _appIdController = TextEditingController(text: settings.firebaseAppId ?? '');
    _senderIdController = TextEditingController(text: settings.firebaseMessagingSenderId ?? '');
    _projectIdController = TextEditingController(text: settings.firebaseProjectId ?? '');
    _storageBucketController = TextEditingController(text: settings.firebaseStorageBucket ?? '');
    _authDomainController = TextEditingController(text: settings.firebaseAuthDomain ?? '');
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _appIdController.dispose();
    _senderIdController.dispose();
    _projectIdController.dispose();
    _storageBucketController.dispose();
    _authDomainController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<SettingsProvider>(context, listen: false);
    
    try {
      await provider.updateFirebaseConfig(
        apiKey: _apiKeyController.text.trim().isEmpty ? null : _apiKeyController.text.trim(),
        appId: _appIdController.text.trim().isEmpty ? null : _appIdController.text.trim(),
        messagingSenderId: _senderIdController.text.trim().isEmpty ? null : _senderIdController.text.trim(),
        projectId: _projectIdController.text.trim().isEmpty ? null : _projectIdController.text.trim(),
        storageBucket: _storageBucketController.text.trim().isEmpty ? null : _storageBucketController.text.trim(),
        authDomain: _authDomainController.text.trim().isEmpty ? null : _authDomainController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully. Please restart the app to apply Firebase configuration changes.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          final settings = provider.settings;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Firebase Configuration Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Firebase Configuration',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Configure Firebase for push notifications. Get these values from your Firebase project settings.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _apiKeyController,
                            decoration: const InputDecoration(
                              labelText: 'API Key',
                              hintText: 'AIza...',
                              helperText: 'From Firebase Project Settings > General',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _appIdController,
                            decoration: const InputDecoration(
                              labelText: 'App ID',
                              hintText: '1:123456789:android:...',
                              helperText: 'From Firebase Project Settings > General',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _senderIdController,
                            decoration: const InputDecoration(
                              labelText: 'Messaging Sender ID',
                              hintText: '123456789',
                              helperText: 'From Firebase Project Settings > Cloud Messaging',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _projectIdController,
                            decoration: const InputDecoration(
                              labelText: 'Project ID',
                              hintText: 'your-project-id',
                              helperText: 'From Firebase Project Settings > General',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _storageBucketController,
                            decoration: const InputDecoration(
                              labelText: 'Storage Bucket (Optional)',
                              hintText: 'your-project-id.appspot.com',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _authDomainController,
                            decoration: const InputDecoration(
                              labelText: 'Auth Domain (Optional)',
                              hintText: 'your-project-id.firebaseapp.com',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveSettings,
                              child: const Text('Save Firebase Configuration'),
                            ),
                          ),
                          if (settings.isFirebaseConfigured) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Firebase is configured',
                                      style: TextStyle(color: Colors.green[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Notification Settings Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Notification Settings',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Enable Notifications'),
                            subtitle: const Text('Receive push notifications'),
                            value: settings.notificationsEnabled,
                            onChanged: (value) {
                              provider.updateNotificationSettings(enabled: value);
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Notification Sound'),
                            subtitle: const Text('Play sound for notifications'),
                            value: settings.notificationsSound,
                            onChanged: settings.notificationsEnabled
                                ? (value) {
                                    provider.updateNotificationSettings(sound: value);
                                  }
                                : null,
                          ),
                          SwitchListTile(
                            title: const Text('Vibration'),
                            subtitle: const Text('Vibrate on notifications'),
                            value: settings.notificationsVibration,
                            onChanged: settings.notificationsEnabled
                                ? (value) {
                                    provider.updateNotificationSettings(vibration: value);
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Help Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'How to Get Firebase Config',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '1. Go to Firebase Console (console.firebase.google.com)',
                          ),
                          const Text(
                            '2. Select your project',
                          ),
                          const Text(
                            '3. Go to Project Settings (gear icon)',
                          ),
                          const Text(
                            '4. Scroll to "Your apps" section',
                          ),
                          const Text(
                            '5. Select your app or add a new one',
                          ),
                          const Text(
                            '6. Copy the configuration values',
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              // Note: In a real app, you might want to use url_launcher
                              // For now, just show a message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Go to: console.firebase.google.com'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open Firebase Console'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
