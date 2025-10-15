// lib/utils/logger.dart

import 'package:flutter/foundation.dart';

/// A professional logging utility for providing clear, formatted, and
/// visually distinct logs during development. Logs are automatically
/// disabled in release builds.
class Logger {
  /// Set this to true in your main() function during development to see
  /// high-frequency logs like location updates.
  static bool enableVerboseLogs = false;

  static void success(String source, String message) {
    if (kDebugMode) {
      debugPrint('✅ [SUCCESS] [$source]: $message');
    }
  }

  // FIX: Added the optional named parameter {bool verbose = false}
  // and logic to handle it.
  static void info(String source, String message, {bool verbose = false}) {
    if (kDebugMode) {
      // If a log is marked as verbose, only show it if verbose logging is enabled.
      // This prevents flooding the console with frequent updates (e.g., location).
      if (verbose && !enableVerboseLogs) {
        return; // Skip this log.
      }
      debugPrint('ℹ️  [INFO] [$source]: $message');
    }
  }

  static void warning(String source, String message) {
    if (kDebugMode) {
      debugPrint('⚠️  [WARNING] [$source]: $message');
    }
  }

  static void error(
    String source,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      debugPrint('🚨 [ERROR] [$source]: $message');
      if (error != null) {
        debugPrint('    L-- 💥 Exception: $error');
      }
      if (stackTrace != null) {
        debugPrint('    L-- 📍 Stack Trace: $stackTrace');
      }
    }
  }
}
