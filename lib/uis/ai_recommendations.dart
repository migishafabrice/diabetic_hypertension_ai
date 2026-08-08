import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../provider/aiProvider.dart';
import '../services/ai_exceptions.dart';
import '../widgets/profile_icon.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/components.dart';

enum RecommendationCategory {
  bloodSugar,
  diet,
  medication,
  exercise,
  complications,
  general,
}

enum DateRangePreset {
  last7,
  last30,
  last90,
  thisMonth,
  lastMonth,
  custom,
}

class AIRecommendationsScreen extends ConsumerStatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  ConsumerState<AIRecommendationsScreen> createState() =>
      _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState
    extends ConsumerState<AIRecommendationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedCategory = 'all';
  int _selectedIndex = 0;
  DateRangePreset _selectedPreset = DateRangePreset.last7;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  final List<String> _categories = [
    'all',
    'Blood Sugar',
    'Diet',
    'Medication',
    'Exercise',
    'Complications',
  ];

  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.microtask(() {
      final dates = _resolvePresetDates(_selectedPreset);
      ref.read(aiRecommendationsProvider.notifier).loadRecommendations(
            startDate: dates.$1,
            endDate: dates.$2,
          );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  (DateTime, DateTime) _resolvePresetDates(DateRangePreset preset, {DateTime? customStart, DateTime? customEnd}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (preset) {
      case DateRangePreset.last7:
        final start = today.subtract(const Duration(days: 6));
        return (start, today);
      case DateRangePreset.last30:
        final start = today.subtract(const Duration(days: 29));
        return (start, today);
      case DateRangePreset.last90:
        final start = today.subtract(const Duration(days: 89));
        return (start, today);
      case DateRangePreset.thisMonth:
        final start = DateTime(today.year, today.month, 1);
        return (start, today);
      case DateRangePreset.lastMonth:
        final start = DateTime(today.year, today.month - 1, 1);
        final end = DateTime(today.year, today.month, 0);
        return (start, end);
      case DateRangePreset.custom:
        final start = customStart ?? today.subtract(const Duration(days: 6));
        final end = customEnd ?? today;
        return (start, end);
    }
  }

  String _getPresetLabel(DateRangePreset preset) {
    switch (preset) {
      case DateRangePreset.last7:
        return 'Last 7 days';
      case DateRangePreset.last30:
        return 'Last 30 days';
      case DateRangePreset.last90:
        return 'Last 90 days';
      case DateRangePreset.thisMonth:
        return 'This month';
      case DateRangePreset.lastMonth:
        return 'Last month';
      case DateRangePreset.custom:
        return 'Custom';
    }
  }

  IconData _getPresetIcon(DateRangePreset preset) {
    switch (preset) {
      case DateRangePreset.last7:
        return Icons.date_range;
      case DateRangePreset.last30:
        return Icons.calendar_month;
      case DateRangePreset.last90:
        return Icons.calendar_view_month;
      case DateRangePreset.thisMonth:
        return Icons.today;
      case DateRangePreset.lastMonth:
        return Icons.calendar_today;
      case DateRangePreset.custom:
        return Icons.edit_calendar;
    }
  }

  String get _currentRangeLabel {
    final dates = _resolvePresetDates(
      _selectedPreset,
      customStart: _customStartDate,
      customEnd: _customEndDate,
    );
    return '${_dateFormat.format(dates.$1)} - ${_dateFormat.format(dates.$2)}';
  }

  Future<void> _loadRecommendations({
    bool force = false,
    bool refreshWithCurrentRange = false,
  }) async {
    DateTime? start;
    DateTime? end;

    if (refreshWithCurrentRange || force) {
      final notifier = ref.read(aiRecommendationsProvider.notifier);
      start = notifier.startDate;
      end = notifier.endDate;
    } else {
      final dates = _resolvePresetDates(
        _selectedPreset,
        customStart: _customStartDate,
        customEnd: _customEndDate,
      );
      start = dates.$1;
      end = dates.$2;
    }

    await ref.read(aiRecommendationsProvider.notifier).loadRecommendations(
          force: force,
          startDate: start,
          endDate: end,
        );
    if (mounted) {
      _animationController.forward(from: 0);
    }
  }

  Future<void> _handlePresetChange(DateRangePreset preset) async {
    if (preset == DateRangePreset.custom) {
      final result = await _showCustomDatePicker();
      if (result == null) return;
      setState(() {
        _customStartDate = result.$1;
        _customEndDate = result.$2;
        _selectedPreset = preset;
      });
      await _loadRecommendations();
    } else {
      setState(() {
        _selectedPreset = preset;
      });
      await _loadRecommendations();
    }
  }

  Future<(DateTime, DateTime)?> _showCustomDatePicker() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final initialStart = _customStartDate ?? today.subtract(const Duration(days: 6));
    final initialEnd = _customEndDate ?? today;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: today,
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd,
      ),
      helpText: 'Select analysis range',
      confirmText: 'Analyze',
      cancelText: 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      return (picked.start, picked.end);
    }
    return null;
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    dashboardWidget(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsState = ref.watch(aiRecommendationsProvider);

    ref.listen<AsyncValue<dynamic>>(aiRecommendationsProvider, (
      previous,
      next,
    ) {
      if (next.hasValue && next.value != null) {
        _animationController.forward(from: 0);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: recommendationsState.when(
                    loading: () => _buildLoadingState(),
                    error: (error, _) => _buildErrorState(error),
                    data: (result) {
                      if (result == null) {
                        return _buildLoadingState();
                      }
                      return _buildRecommendationsContent(
                        result.toDisplayMap(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF4CAF50),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF8BC34A), Color(0xFFAED581)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DiaCare AI Health Coach',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Personalized diabetes management',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        const ProfileIcon(),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => _loadRecommendations(force: true),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lotties/Happy_Face_Loading.json',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyzing your health data...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generating personalized recommendations',
            style: TextStyle(fontSize: 14, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  String _errorTitle(Object error) {
    final aiError = error is AiServiceException
        ? error
        : AiServiceException.fromError(error);

    switch (aiError.type) {
      case AiFailureType.quotaExceeded:
        return 'Rate Limit Reached';
      case AiFailureType.timeout:
        return 'Request Timed Out';
      case AiFailureType.authentication:
        return 'API Key Problem';
      case AiFailureType.network:
        return 'Connection Problem';
      case AiFailureType.invalidRequest:
        return 'Request Rejected';
      case AiFailureType.invalidResponse:
        return 'Could Not Read AI Response';
      case AiFailureType.modelNotFound:
        return 'Model Not Available';
      case AiFailureType.configuration:
        return 'AI Not Configured';
      case AiFailureType.unavailable:
        return 'AI Service Busy';
      case AiFailureType.unknown:
        return 'Unable to Generate Recommendations';
    }
  }

  String _resolveErrorMessage(Object error) {
    if (error is AiServiceException) {
      return error.userMessage;
    }
    return AiServiceException.fromError(error).userMessage;
  }

  bool _isRateLimitError(Object error) {
    if (error is AiServiceException) {
      return error.type == AiFailureType.quotaExceeded;
    }
    return _isRateLimitMessage(error.toString());
  }

  bool _isRateLimitMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('429') ||
        lower.contains('rate limit') ||
        lower.contains('quota');
  }

  Widget _buildErrorState(Object error) {
    final errorMessage = _resolveErrorMessage(error);
    final title = _errorTitle(error);
    final isQuota = _isRateLimitError(error);

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isQuota ? Icons.hourglass_empty : Icons.error_outline,
            size: 80,
            color: Colors.orange.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'All other app features remain available.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: isQuota ? null : () => _loadRecommendations(force: true),
            icon: const Icon(Icons.refresh),
            label: Text(isQuota ? 'Wait and try later' : 'Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsContent(Map<String, dynamic> recommendations) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 16),
          _buildCategoryFilter(),
          if (recommendations['cdriScore'] != null ||
              recommendations['riskClassification'] != null) ...[
            const SizedBox(height: 20),
            _buildCdriSummary(recommendations),
          ],
          const SizedBox(height: 20),
          _buildRecommendations(recommendations),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analysis Period',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _loadRecommendations(force: true, refreshWithCurrentRange: true),
                  icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF4CAF50)),
                  label: const Text(
                    'Refresh',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Text(
                _currentRangeLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DateRangePreset.values.map((preset) {
                  final isSelected = _selectedPreset == preset;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPresetIcon(preset),
                            size: 16,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(_getPresetLabel(preset)),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) => _handlePresetChange(preset),
                      selectedColor: const Color(0xFF4CAF50),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCdriSummary(Map<String, dynamic> recommendations) {
    final cdriScore = recommendations['cdriScore'];
    final riskClassification = recommendations['riskClassification'];
    final factors =
        recommendations['contributingFactors'] as List<dynamic>? ?? [];

    Color riskColor;
    switch ((riskClassification as String?)?.toLowerCase()) {
      case 'low':
        riskColor = Colors.green;
        break;
      case 'moderate':
        riskColor = Colors.orange;
        break;
      case 'high':
        riskColor = Colors.red;
        break;
      default:
        riskColor = const Color(0xFF4CAF50);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Health Indicators',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (cdriScore != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cdriScore.toString(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const Text('Composite score (CDRI)'),
                    ],
                  ),
                ),
              if (riskClassification != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Risk level: $riskClassification',
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (factors.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Key Indicators',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...factors.map(
              (factor) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('- $factor'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category == 'all' ? 'All' : category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : 'all';
                });
              },
              selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
              checkmarkColor: const Color(0xFF4CAF50),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendations(Map<String, dynamic> recommendations) {
    final recommendationsText = recommendations['recommendations'] ?? '';

    if (recommendationsText.isEmpty) {
      return const Center(child: Text('No recommendations available'));
    }

    final sections = _parseRecommendations(recommendationsText);
    final filtered = _applyCategoryFilter(sections);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final section = filtered[index];
        return _buildRecommendationCard(
          section['title'] ?? 'Recommendation',
          section['content'] ?? '',
          section['icon'] ?? Icons.lightbulb,
          section['color'] ?? const Color(0xFF4CAF50),
        );
      },
    );
  }

  List<Map<String, dynamic>> _applyCategoryFilter(
    List<Map<String, dynamic>> sections,
  ) {
    if (_selectedCategory == 'all') return sections;

    bool matches(Map<String, dynamic> section) {
      final title = (section['title'] ?? '').toString().toLowerCase();
      final content = (section['content'] ?? '').toString().toLowerCase();
      final text = '$title\n$content';

      switch (_selectedCategory.toLowerCase()) {
        case 'blood sugar':
          return text.contains('glucose') ||
              text.contains('hba1c') ||
              text.contains('blood sugar') ||
              text.contains('fasting') ||
              text.contains('random') ||
              title.contains('vital sign') ||
              title.contains('current risk');
        case 'diet':
          return text.contains('diet') || text.contains('nutrition');
        case 'medication':
          return text.contains('medication') || text.contains('adherence');
        case 'exercise':
          return text.contains('exercise') ||
              text.contains('activity') ||
              text.contains('physical');
        case 'complications':
          return text.contains('complication') ||
              text.contains('kidney') ||
              text.contains('retinopathy') ||
              text.contains('cardio') ||
              title.contains('symptoms analysis') ||
              title.contains('complication risk');
        default:
          return true;
      }
    }

    return sections.where(matches).toList();
  }

  List<Map<String, dynamic>> _parseRecommendations(String text) {
    final sections = <Map<String, dynamic>>[];

    final lines = text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    String currentTitle = 'Overview';
    StringBuffer currentContent = StringBuffer();
    IconData currentIcon = Icons.lightbulb;
    Color currentColor = const Color(0xFF4CAF50);

    for (var line in lines) {
      final lowerLine = line.toLowerCase();

      if (lowerLine.contains('self management')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Self Management Tips';
        currentIcon = Icons.self_improvement;
        currentColor = const Color(0xFF4CAF50);
      } else if (lowerLine.contains('vital sign') ||
          lowerLine.contains('measurements of vital')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Vital Signs';
        currentIcon = Icons.monitor_heart;
        currentColor = const Color(0xFF2E7D32);
      } else if (lowerLine.contains('symptoms analysis')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Symptoms Analysis';
        currentIcon = Icons.health_and_safety;
        currentColor = const Color(0xFF2196F3);
      } else if (lowerLine.contains('current risk') ||
          lowerLine.contains('overall health') ||
          lowerLine.contains('health assessment')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Current Risk Level';
        currentIcon = Icons.monitor_heart;
        currentColor = const Color(0xFFE53935);
      } else if (lowerLine.contains('contributing') ||
          lowerLine.contains('factors contributing')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Contributing Factors';
        currentIcon = Icons.analytics_outlined;
        currentColor = const Color(0xFFFF5722);
      } else if (lowerLine.contains('interpretation')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Interpretation';
        currentIcon = Icons.info_outline;
        currentColor = const Color(0xFF2196F3);
      } else if (lowerLine.contains('motivation') ||
          lowerLine.contains('encourag')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Motivation';
        currentIcon = Icons.favorite_outline;
        currentColor = const Color(0xFFE91E63);
      } else if (lowerLine.contains('diet') ||
          lowerLine.contains('nutrition')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Diet & Nutrition';
        currentIcon = Icons.restaurant;
        currentColor = const Color(0xFFFF9800);
      } else if (lowerLine.contains('exercise') ||
          lowerLine.contains('physical')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Exercise & Activity';
        currentIcon = Icons.fitness_center;
        currentColor = const Color(0xFF9C27B0);
      } else if (lowerLine.contains('medication')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Medication';
        currentIcon = Icons.medication;
        currentColor = const Color(0xFF2196F3);
      } else if (lowerLine.contains('complication') ||
          lowerLine.contains('risk')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Complication Risk';
        currentIcon = Icons.warning;
        currentColor = const Color(0xFFFF5722);
      } else if (lowerLine.contains('next step') ||
          lowerLine.contains('actionable')) {
        if (currentContent.isNotEmpty) {
          sections.add({
            'title': currentTitle,
            'content': currentContent.toString(),
            'icon': currentIcon,
            'color': currentColor,
          });
          currentContent.clear();
        }
        currentTitle = 'Actionable Steps';
        currentIcon = Icons.checklist;
        currentColor = const Color(0xFF4CAF50);
      } else {
        if (currentContent.isNotEmpty) {
          currentContent.write('\n');
        }
        currentContent.write(line.trim());
      }
    }

    if (currentContent.isNotEmpty) {
      sections.add({
        'title': currentTitle,
        'content': currentContent.toString(),
        'icon': currentIcon,
        'color': currentColor,
      });
    }

    if (sections.isEmpty) {
      sections.add({
        'title': 'Health Recommendations',
        'content': text,
        'icon': Icons.lightbulb,
        'color': const Color(0xFF4CAF50),
      });
    }

    return sections;
  }

  Widget _buildRecommendationCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFormattedContent(content),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    final lines = content
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lines.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final line = lines[index].trim();

        if (line.startsWith('-') ||
            line.startsWith('•') ||
            line.startsWith('*')) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  line.substring(1).trim(),
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          );
        } else if (line.endsWith(':') || line.endsWith('：')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
          );
        } else {
          return Text(
            line,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.6,
            ),
          );
        }
      },
    );
  }
}
