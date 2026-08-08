import 'ai_logger.dart';

enum AiFailureType {
  configuration,
  authentication,
  quotaExceeded,
  modelNotFound,
  invalidRequest,
  invalidResponse,
  timeout,
  network,
  unavailable,
  unknown,
}

class AiServiceException implements Exception {
  final AiFailureType type;
  final String message;
  final String userMessage;
  final int? statusCode;
  final String? responseBody;
  final Duration? retryAfter;
  final Object? cause;

  const AiServiceException({
    required this.type,
    required this.message,
    required this.userMessage,
    this.statusCode,
    this.responseBody,
    this.retryAfter,
    this.cause,
  });

  /// Only transient network issues should be retried automatically.
  bool get isRetryable =>
      type == AiFailureType.network || type == AiFailureType.timeout;

  /// When true, do not hammer fallback services — fail fast to the user.
  bool get shouldFailFast =>
      type == AiFailureType.quotaExceeded ||
      type == AiFailureType.authentication ||
      type == AiFailureType.invalidRequest ||
      type == AiFailureType.configuration;

  @override
  String toString() {
    final buffer = StringBuffer('AiServiceException($type): $message');
    if (statusCode != null) buffer.write(' [status=$statusCode]');
    if (cause != null) buffer.write(' | cause=${cause.runtimeType}: $cause');
    if (responseBody != null && responseBody!.isNotEmpty) {
      buffer.write(' | response=$responseBody');
    }
    return buffer.toString();
  }

  static AiServiceException fromError(
    Object error, {
    StackTrace? stackTrace,
  }) {
    if (error is AiServiceException) {
      _debugLog('AiServiceException.fromError (already mapped)', error, stackTrace);
      return error;
    }

    final text = error.toString();
    final lower = text.toLowerCase();
    final errorTypeName = error.runtimeType.toString();

    _debugLog(
      'AiServiceException.fromError mapping raw error',
      error,
      stackTrace,
      extra: {'errorType': errorTypeName, 'raw': text},
    );

    if (lower.contains('gemini_api_key') ||
        lower.contains('api_key_invalid') ||
        lower.contains('invalid api key')) {
      return AiServiceException(
        type: AiFailureType.authentication,
        message: text,
        userMessage:
            'The Gemini API key is missing or invalid. Update GEMINI_API_KEY in the app configuration.\n\nDebug: $errorTypeName — $text',
        cause: error,
      );
    }

    if (_isQuotaError(lower)) {
      return quotaExceeded(text, cause: error);
    }

    if (lower.contains('bad request') || lower.contains('400')) {
      return AiServiceException(
        type: AiFailureType.invalidRequest,
        message: text,
        userMessage:
            'The AI request was rejected by Gemini (HTTP 400).\n\nDebug: $errorTypeName — $text',
        statusCode: 400,
        cause: error,
      );
    }

    if (lower.contains('not found') ||
        lower.contains('is no longer available') ||
        lower.contains('404')) {
      return AiServiceException(
        type: AiFailureType.modelNotFound,
        message: text,
        userMessage:
            'The configured Gemini model is unavailable (HTTP 404). Update GEMINI_MODEL in .env.\n\nDebug: $errorTypeName — $text',
        statusCode: 404,
        cause: error,
      );
    }

    if (lower.contains('timeout') || lower.contains('timed out')) {
      return AiServiceException(
        type: AiFailureType.timeout,
        message: text,
        userMessage:
            'The AI request timed out.\n\nDebug: $errorTypeName — $text',
        cause: error,
      );
    }

    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('clientexception') ||
        lower.contains('handshakeexception')) {
      return AiServiceException(
        type: AiFailureType.network,
        message: text,
        userMessage:
            'Unable to reach the AI service.\n\nDebug: $errorTypeName — $text',
        cause: error,
      );
    }

    if (lower.contains('jsonunsupportedobjecterror') ||
        lower.contains('encodable object failed') ||
        lower.contains('not json-encodable') ||
        lower.contains('empty response') ||
        lower.contains('invalid json')) {
      return AiServiceException(
        type: AiFailureType.invalidResponse,
        message: text,
        userMessage:
            'The AI request data could not be prepared correctly.\n\nDebug: $errorTypeName — $text',
        cause: error,
      );
    }

    // Unknown — include full raw error so it can be traced in the UI + console.
    final unknown = AiServiceException(
      type: AiFailureType.unknown,
      message: text,
      userMessage:
          'Could not generate recommendations.\n\n'
          'Error type: $errorTypeName\n'
          'Details: $text',
      cause: error,
    );

    _debugLog('AiServiceException UNKNOWN mapped', unknown, stackTrace);
    return unknown;
  }

  static AiServiceException quotaExceeded(
    String message, {
    Object? cause,
  }) {
    final retryAfter = _parseRetryAfter(message);
    final retryHint = retryAfter != null
        ? ' Please wait about ${retryAfter.inSeconds} seconds before trying again.'
        : ' Please wait a minute before trying again.';

    final exception = AiServiceException(
      type: AiFailureType.quotaExceeded,
      message: message,
      userMessage:
          'Gemini free-tier rate limit reached (HTTP 429).$retryHint\n\nDebug: $message',
      statusCode: 429,
      retryAfter: retryAfter,
      cause: cause,
    );
    _debugLog('AiServiceException quotaExceeded', exception, null);
    return exception;
  }

  /// Temporary console logging — remove prints after debugging.
  static void _debugLog(
    String label,
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? extra,
  }) {
    // ignore: avoid_print
    print('========== AI ERROR TRACE ==========');
    // ignore: avoid_print
    print('[AI] $label');
    // ignore: avoid_print
    print('[AI] errorType=${error.runtimeType}');
    // ignore: avoid_print
    print('[AI] error=$error');
    if (error is AiServiceException) {
      // ignore: avoid_print
      print('[AI] failureType=${error.type}');
      // ignore: avoid_print
      print('[AI] message=${error.message}');
      // ignore: avoid_print
      print('[AI] userMessage=${error.userMessage}');
      // ignore: avoid_print
      print('[AI] statusCode=${error.statusCode}');
      // ignore: avoid_print
      print('[AI] responseBody=${error.responseBody}');
      // ignore: avoid_print
      print('[AI] cause=${error.cause}');
    }
    if (extra != null && extra.isNotEmpty) {
      // ignore: avoid_print
      print('[AI] extra=$extra');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('[AI] stackTrace=\n$stackTrace');
    }
    // ignore: avoid_print
    print('====================================');

    AiLogger.error(label, error: error, stackTrace: stackTrace, data: extra);
  }

  static bool _isQuotaError(String lower) {
    return lower.contains('quota') ||
        lower.contains('resource_exhausted') ||
        lower.contains('rate limit') ||
        lower.contains('too many requests') ||
        lower.contains('429');
  }

  static Duration? _parseRetryAfter(String text) {
    final match = RegExp(
      r'retry in (\d+(?:\.\d+)?)s',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    final seconds = double.tryParse(match.group(1) ?? '');
    if (seconds == null) return null;
    return Duration(milliseconds: (seconds * 1000).round());
  }
}
