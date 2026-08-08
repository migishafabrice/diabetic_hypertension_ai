import 'dart:convert';
import 'dart:developer' as developer;

class AiLogger {
  static const _name = 'AiService';

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    // Temporary console logging for device/emulator logcat — remove later.
    // ignore: avoid_print
    print('[AiLogger.ERROR] $message | data=$data | error=$error');
    if (stackTrace != null) {
      // ignore: avoid_print
      print('[AiLogger.ERROR] stackTrace:\n$stackTrace');
    }

    developer.log(
      _format(message, data),
      name: _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(String message, {Map<String, Object?>? data}) {
    // ignore: avoid_print
    print('[AiLogger.INFO] ${_format(message, data)}');
    developer.log(_format(message, data), name: _name);
  }

  static void warning(String message, {Map<String, Object?>? data}) {
    // ignore: avoid_print
    print('[AiLogger.WARN] ${_format(message, data)}');
    developer.log(_format(message, data), name: _name, level: 900);
  }

  static void logRequest({
    required String provider,
    required String model,
    required Map<String, dynamic> payload,
  }) {
    info(
      'AI request prepared',
      data: {
        'provider': provider,
        'model': model,
        'payload': _sanitizePayload(payload),
      },
    );
  }

  static void logResponse({
    required String provider,
    required String model,
    required String responsePreview,
    int? statusCode,
  }) {
    info(
      'AI response received',
      data: {
        'provider': provider,
        'model': model,
        'statusCode': statusCode,
        'responsePreview': _truncate(responsePreview, 500),
      },
    );
  }

  static Map<String, dynamic> _sanitizePayload(Map<String, dynamic> payload) {
    final clone = jsonDecode(jsonEncode(payload)) as Map<String, dynamic>;
    return clone;
  }

  static String _format(String message, Map<String, Object?>? data) {
    if (data == null || data.isEmpty) return message;
    return '$message | ${jsonEncode(data)}';
  }

  static String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}...';
  }
}
