# Error Tracking Guide

This guide explains how to track and monitor errors in the EMS Mobile App.

## Overview

The app includes a comprehensive error tracking system that:
- Logs all errors, warnings, and important events
- Stores logs locally on the device
- Displays errors in the console during development
- Provides tools to view and export logs

## How Errors Are Tracked

### 1. **Automatic Error Tracking**

The app automatically tracks:
- **Flutter Framework Errors**: Widget errors, rendering issues
- **Platform Errors**: Async errors, unhandled exceptions
- **API Errors**: Network failures, authentication errors
- **Service Errors**: Firebase, storage, notification errors

### 2. **Manual Error Logging**

You can manually log errors in your code:

```dart
import 'core/services/error_logger_service.dart';
import 'core/utils/error_handler.dart';

// Get the logger
final logger = ErrorHandler.logger;

// Log different types of messages
await logger?.info('User logged in successfully');
await logger?.warning('API response took longer than expected');
await logger?.error('Failed to load data', error: exception, stackTrace: stackTrace);
await logger?.fatal('Critical system failure', error: exception, stackTrace: stackTrace);

// Log with context
await logger?.error(
  'Login failed',
  error: exception,
  context: {
    'username': username,
    'timestamp': DateTime.now().toIso8601String(),
  },
);
```

## Viewing Errors

### During Development

1. **Console Output**: Errors are automatically printed to the console with emojis:
   - 🐛 Debug messages
   - ℹ️ Info messages
   - ⚠️ Warning messages
   - ❌ Error messages
   - 💀 Fatal errors

2. **Flutter DevTools**: 
   - Open DevTools: `flutter pub global activate devtools`
   - Run: `flutter pub global run devtools`
   - Connect to your running app

3. **Run with Verbose Logging**:
   ```bash
   flutter run -d <device> --verbose
   ```

### In Production

1. **Logs are stored locally** on the device
2. **View logs in Settings** (if you add a logs viewer screen)
3. **Export logs** for analysis

## Error Log Levels

- **DEBUG**: Detailed information for debugging
- **INFO**: General informational messages
- **WARNING**: Warning messages for potential issues
- **ERROR**: Error messages for handled exceptions
- **FATAL**: Critical errors that may cause app crashes

## Best Practices

### 1. Log Important Events

```dart
// Good: Log important user actions
await logger?.info('User viewed student profile', context: {'student_id': studentId});

// Good: Log API calls
await logger?.debug('Fetching student data', context: {'endpoint': '/api/students'});
```

### 2. Log Errors with Context

```dart
// Good: Include context information
try {
  await apiService.fetchData();
} catch (e, stackTrace) {
  await logger?.error(
    'Failed to fetch data',
    error: e,
    stackTrace: stackTrace,
    context: {
      'endpoint': '/api/data',
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
```

### 3. Use Appropriate Log Levels

```dart
// Debug: Detailed debugging info
await logger?.debug('Processing request', context: {'request_id': requestId});

// Info: Normal operations
await logger?.info('User logged in', context: {'user_id': userId});

// Warning: Potential issues
await logger?.warning('Slow API response', context: {'duration': '5s'});

// Error: Handled exceptions
await logger?.error('API call failed', error: exception);

// Fatal: Critical errors
await logger?.fatal('Database connection lost', error: exception, stackTrace: stackTrace);
```

## Advanced: Adding Firebase Crashlytics

For production error tracking, you can integrate Firebase Crashlytics:

1. **Add dependency** to `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_crashlytics: ^3.4.0
   ```

2. **Initialize in main.dart**:
   ```dart
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Initialize Firebase Crashlytics
     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
     PlatformDispatcher.instance.onError = (error, stack) {
       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
       return true;
     };
     
     // ... rest of initialization
   }
   ```

3. **Log custom events**:
   ```dart
   FirebaseCrashlytics.instance.log('User performed action');
   FirebaseCrashlytics.instance.setCustomKey('user_id', userId);
   ```

## Viewing Logs Programmatically

```dart
// Get all logs
final allLogs = errorLogger.logs;

// Get error logs only
final errorLogs = errorLogger.getErrorLogs(limit: 10);

// Get logs by level
final warningLogs = errorLogger.getLogsByLevel(LogLevel.warning);

// Export logs as JSON
final logsJson = errorLogger.exportLogs();

// Clear logs
await errorLogger.clearLogs();
```

## Common Error Scenarios

### API Errors
```dart
try {
  final response = await apiService.callRPC('model', 'method', []);
} on DioException catch (e) {
  await logger?.error(
    'API request failed',
    error: e,
    context: {
      'url': e.requestOptions.uri.toString(),
      'status_code': e.response?.statusCode,
    },
  );
}
```

### Authentication Errors
```dart
try {
  await authService.login(username, password);
} catch (e, stackTrace) {
  await logger?.error(
    'Login failed',
    error: e,
    stackTrace: stackTrace,
    context: {'username': username},
  );
}
```

### Storage Errors
```dart
try {
  await storageService.saveString('key', 'value');
} catch (e) {
  await logger?.error('Failed to save data', error: e);
}
```

## Tips

1. **Don't log sensitive information** (passwords, tokens, etc.)
2. **Use context** to provide useful debugging information
3. **Log at appropriate levels** - don't log everything as errors
4. **Review logs regularly** to identify patterns
5. **Clear old logs** periodically to save storage space

## Troubleshooting

If errors aren't being logged:
1. Check that `ErrorHandler.initialize()` is called in `main()`
2. Verify the logger is not null before using it
3. Check console output for any initialization errors
4. Ensure storage service is properly initialized
