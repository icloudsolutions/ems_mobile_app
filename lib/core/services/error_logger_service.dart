import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class ErrorLoggerService {
  final StorageService _storageService;
  static const String _logKey = 'app_logs';
  static const int _maxLogs = 100; // Keep last 100 logs
  final List<LogEntry> _logs = [];
  final StreamController<LogEntry> _logController = StreamController<LogEntry>.broadcast();

  ErrorLoggerService({required StorageService storageService})
      : _storageService = storageService {
    // Load logs synchronously (getString is synchronous)
    _loadLogsSync();
  }

  Stream<LogEntry> get logStream => _logController.stream;
  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// Log a message with specified level
  Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    try {
      final entry = LogEntry(
        message: message,
        level: level,
        timestamp: DateTime.now(),
        error: error?.toString(),
        stackTrace: stackTrace?.toString(),
        context: context,
      );

      _logs.add(entry);
      
      // Keep only last N logs in memory
      if (_logs.length > _maxLogs) {
        _logs.removeAt(0);
      }

      // Emit to stream (only if controller is not closed)
      if (!_logController.isClosed) {
        _logController.add(entry);
      }

      // Print to console in debug mode
      if (kDebugMode) {
        final emoji = _getEmojiForLevel(level);
        print('$emoji [${level.name.toUpperCase()}] $message');
        if (error != null) {
          print('   Error: $error');
        }
        if (stackTrace != null) {
          print('   StackTrace: $stackTrace');
        }
        if (context != null && context.isNotEmpty) {
          print('   Context: $context');
        }
      }

      // Save to storage (don't let storage errors crash logging)
      try {
        await _saveLogs();
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Failed to save log to storage: $e');
        }
      }
    } catch (e) {
      // If logging itself fails, just print to console
      if (kDebugMode) {
        print('Error in logger: $e');
        print('Original message: $message');
      }
    }
  }

  /// Log debug message
  Future<void> debug(String message, {Map<String, dynamic>? context}) async {
    await log(message, level: LogLevel.debug, context: context);
  }

  /// Log info message
  Future<void> info(String message, {Map<String, dynamic>? context}) async {
    await log(message, level: LogLevel.info, context: context);
  }

  /// Log warning
  Future<void> warning(String message, {Object? error, Map<String, dynamic>? context}) async {
    await log(message, level: LogLevel.warning, error: error, context: context);
  }

  /// Log error
  Future<void> error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await log(message, level: LogLevel.error, error: error, stackTrace: stackTrace, context: context);
  }

  /// Log fatal error
  Future<void> fatal(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await log(message, level: LogLevel.fatal, error: error, stackTrace: stackTrace, context: context);
  }

  /// Log exception
  Future<void> logException(Object exception, StackTrace stackTrace, {Map<String, dynamic>? context}) async {
    await error(
      'Exception: ${exception.toString()}',
      error: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Get logs filtered by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Get recent error logs
  List<LogEntry> getErrorLogs({int? limit}) {
    final errorLogs = _logs.where((log) => 
      log.level == LogLevel.error || log.level == LogLevel.fatal
    ).toList();
    
    if (limit != null && errorLogs.length > limit) {
      return errorLogs.sublist(errorLogs.length - limit);
    }
    return errorLogs;
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    _logs.clear();
    await _storageService.remove(_logKey);
    _logController.add(LogEntry(
      message: 'Logs cleared',
      level: LogLevel.info,
      timestamp: DateTime.now(),
    ));
  }

  /// Export logs as JSON
  String exportLogs() {
    final logsJson = _logs.map((log) => log.toJson()).toList();
    return jsonEncode(logsJson);
  }

  void _loadLogsSync() {
    try {
      final logsJson = _storageService.getString(_logKey);
      if (logsJson != null && logsJson.isNotEmpty) {
        final List<dynamic> logsList = jsonDecode(logsJson);
        _logs.clear();
        _logs.addAll(logsList.map((json) => LogEntry.fromJson(json as Map<String, dynamic>)));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading logs: $e');
      }
      // If loading fails, just start with empty logs
      _logs.clear();
    }
  }

  Future<void> _saveLogs() async {
    try {
      // Keep only last 50 logs in storage to save space
      final logsToSave = _logs.length > 50 
          ? _logs.sublist(_logs.length - 50)
          : _logs;
      
      final logsJson = jsonEncode(logsToSave.map((log) => log.toJson()).toList());
      await _storageService.saveString(_logKey, logsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving logs: $e');
      }
    }
  }

  String _getEmojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💀';
    }
  }

  void dispose() {
    _logController.close();
  }
}

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final String? error;
  final String? stackTrace;
  final Map<String, dynamic>? context;

  LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
    this.error,
    this.stackTrace,
    this.context,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      message: json['message'] as String,
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String?,
      stackTrace: json['stackTrace'] as String?,
      context: json['context'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'level': level.name,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
      'stackTrace': stackTrace,
      'context': context,
    };
  }

  @override
  String toString() {
    return '[${level.name.toUpperCase()}] $message${error != null ? ' - Error: $error' : ''}';
  }
}
