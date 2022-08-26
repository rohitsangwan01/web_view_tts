// main.dart
import 'dart:developer' as developer;

bool showLogs = true;
String _errorColor = '\x1B[31m';
String _successColor = '\x1B[32m';
String _warningColor = '\x1B[33m';
String _infoColor = '\x1B[34m';
String _logName = "WebViewTTS";

// Blue text
void logInfo(String msg) {
  if (!showLogs) return;
  developer.log('$_infoColor$msg$_infoColor', name: _logName);
}

// Green text
void logSuccess(String msg) {
  if (!showLogs) return;
  developer.log('$_successColor$msg$_successColor', name: _logName);
}

// Yellow text
void logWarning(String msg) {
  if (!showLogs) return;
  developer.log('$_warningColor$msg$_warningColor', name: _logName);
}

// Red text
void logError(String msg) {
  if (!showLogs) return;
  developer.log('$_errorColor$msg$_errorColor', name: _logName);
}
