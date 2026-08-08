import '../models/ai_analysis_models.dart';
import '../models/local_user.dart';
import 'ai_exceptions.dart';
import 'gemini_ai_service.dart';
import 'health_data_aggregator.dart';

class AiAnalysisRepository {
  final HealthDataAggregator _aggregator;
  final AiAnalysisService _primaryService;

  AiAnalysisRepository({
    HealthDataAggregator? aggregator,
    AiAnalysisService? primaryService,
  })  : _aggregator = aggregator ?? HealthDataAggregator(),
        _primaryService = primaryService ?? GeminiAiAnalysisService();

  Future<AiAnalysisResult> getRecommendations(
    LocalUser user, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (user.id == null) {
      throw const AiServiceException(
        type: AiFailureType.configuration,
        message: 'User ID is required for AI analysis',
        userMessage: 'Please log in before requesting AI recommendations.',
      );
    }

    final request = await _aggregator.buildRequest(
      user,
      startDate: startDate,
      endDate: endDate,
    );
    return _primaryService.analyze(request);
  }
}
