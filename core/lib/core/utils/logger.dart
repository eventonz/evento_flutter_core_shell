class Logger {
  static bool _isDevMode = true;

  /// Sets whether the logger is in development mode
  static void setDevMode(bool value) {
    _isDevMode = value;
  }

  /// Logs a debug message
  static void d(String message) {
    if (_isDevMode) {
      print('🔍 DEBUG: $message');
    }
  }

  /// Logs an info message
  static void i(String message) {
    if (_isDevMode) {
      print('ℹ️ INFO: $message');
    }
  }

  /// Logs a warning message
  static void w(String message) {
    if (_isDevMode) {
      print('⚠️ WARN: $message');
    }
  }

  /// Logs an error message
  static void e(String message) {
    if (_isDevMode) {
      print('❌ ERROR: $message');
    }
  }
}
