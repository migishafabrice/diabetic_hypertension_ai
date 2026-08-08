import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_analysis_models.dart';
import '../models/local_user.dart';
import '../services/ai_analysis_repository.dart';
import '../services/ai_exceptions.dart';
import 'authProvider.dart';

final aiAnalysisRepositoryProvider = Provider<AiAnalysisRepository>((ref) {
  return AiAnalysisRepository();
});

final aiRecommendationsProvider =
    StateNotifierProvider<AiRecommendationsNotifier, AsyncValue<AiAnalysisResult?>>(
  (ref) => AiRecommendationsNotifier(ref),
);

class AiRecommendationsNotifier
    extends StateNotifier<AsyncValue<AiAnalysisResult?>> {
  final Ref _ref;
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  AiRecommendationsNotifier(this._ref) : super(const AsyncValue.data(null));

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  void setDateRange({DateTime? startDate, DateTime? endDate}) {
    _startDate = startDate;
    _endDate = endDate;
  }

  Future<void> loadRecommendations({
    bool force = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_isLoading) return;

    if (startDate != null || endDate != null) {
      setDateRange(startDate: startDate, endDate: endDate);
    }

    final user = _ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error(
        const AiServiceException(
          type: AiFailureType.configuration,
          message: 'User not logged in',
          userMessage: 'Please log in before requesting AI recommendations.',
        ),
        StackTrace.current,
      );
      return;
    }

    _isLoading = true;
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(aiAnalysisRepositoryProvider);
      final result = await repository.getRecommendations(
        user,
        startDate: _startDate,
        endDate: _endDate,
      );
      state = AsyncValue.data(result);
    } on AiServiceException catch (error, stackTrace) {
      // Temporary debug prints — remove after tracing the failure.
      // ignore: avoid_print
      print('[AI Provider] AiServiceException: $error');
      // ignore: avoid_print
      print('[AI Provider] stackTrace:\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      // Temporary debug prints — remove after tracing the failure.
      // ignore: avoid_print
      print('[AI Provider] unexpected error type=${error.runtimeType}');
      // ignore: avoid_print
      print('[AI Provider] unexpected error=$error');
      // ignore: avoid_print
      print('[AI Provider] stackTrace:\n$stackTrace');
      state = AsyncValue.error(
        AiServiceException.fromError(error, stackTrace: stackTrace),
        stackTrace,
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() => loadRecommendations(force: true);
}

Future<AiAnalysisResult> getAiRecommendationsForUser(LocalUser user) {
  return AiAnalysisRepository().getRecommendations(user);
}
