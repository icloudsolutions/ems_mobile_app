import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/error_logger_service.dart';

/// Global error handler for Flutter errors
class ErrorHandler {
  static ErrorLoggerService? _logger;

  static void initialize(ErrorLoggerService logger) {
    _logger = logger;
    
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger?.fatal(
        'Flutter Error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
          'informationCollector': details.informationCollector?.toString(),
        },
      );
      
      // In debug mode, also use Flutter's default error handler
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // Handle async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logger?.fatal(
        'Platform Error: $error',
        error: error,
        stackTrace: stack,
      );
      return true;
    };
  }

  /// Get the logger instance
  static ErrorLoggerService? get logger => _logger;
}
