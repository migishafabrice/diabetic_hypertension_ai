import 'package:flutter_test/flutter_test.dart';
import 'package:diacare/models/ai_analysis_models.dart';
import 'package:diacare/models/local_user.dart';
import 'package:diacare/services/ai_exceptions.dart';

void main() {
  test('AiServiceException does not retry quota errors', () {
    const error = AiServiceException(
      type: AiFailureType.quotaExceeded,
      message: 'quota',
      userMessage: 'quota',
      statusCode: 429,
    );

    expect(error.isRetryable, isFalse);
    expect(error.shouldFailFast, isTrue);
  });

  test('AiServiceException maps quota errors from message', () {
    const message =
        'You exceeded your current quota, please check your plan. Please retry in 36s.';
    final error = AiServiceException.fromError(message);

    expect(error.type, AiFailureType.quotaExceeded);
    expect(error.statusCode, 429);
    expect(error.retryAfter, isNotNull);
    expect(error.userMessage.toLowerCase(), contains('rate limit'));
  });

  test('AiAnalysisResult parses valid Gemini JSON', () {
    final result = AiAnalysisResult.fromJson(
      {
        'cdriScore': 72.5,
        'riskClassification': 'Moderate',
        'contributingFactors': ['Elevated HbA1c'],
        'recommendations': ['Increase daily walking'],
        'summary': 'Moderate risk profile.',
      },
      provider: 'gemini',
      model: 'gemini-3.6-flash',
    );

    result.validate();

    expect(result.cdriScore, 72.5);
    expect(result.riskClassification, 'Moderate');
    expect(result.recommendations, ['Increase daily walking']);
    expect(result.formattedText, contains('CDRI'));
  });

  test('LocalUser serializes sex field', () {
    final user = LocalUser(
      username: 'patient@example.com',
      password: 'hash',
      sex: 'Female',
      smokingStatus: 'Never Smoked',
      alcoholConsumption: 'Occasionally',
    );

    final map = user.toMap();
    expect(map['sex'], 'Female');

    final restored = LocalUser.fromMap(map);
    expect(restored.sex, 'Female');
  });
}
