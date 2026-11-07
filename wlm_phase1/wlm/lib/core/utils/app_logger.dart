import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralised logger. Use AppLogger.i/d/w/e throughout the app.
/// Logs are suppressed in release builds.
abstract final class AppLogger {
  static late final Logger _logger;

  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
      level: kDebugMode ? Level.trace : Level.off,
    );
  }

  static void d(String message, [Object? error]) =>
      _logger.d(message, error: error);

  static void i(String message, [Object? error]) =>
      _logger.i(message, error: error);

  static void w(String message, [Object? error]) =>
      _logger.w(message, error: error);

  static void e(String message, [Object? error, StackTrace? stack]) =>
      _logger.e(message, error: error, stackTrace: stack);
}
