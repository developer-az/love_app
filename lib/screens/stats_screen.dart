import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/widgets/premium_components.dart';

class StatsScreen extends StatefulWidget {
  final MemoryService memoryService;

  const StatsScreen({super.key, required this.memoryService});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Memory> _memories = [];
  bool _isLoading = true;

  Memory? _cachedOldestMemory;
  Map<String, int>? _cachedMonthlyStats;
  int? _cachedMaxCount;
  List<MapEntry<String, int>>? _cachedTopLocations;
  int? _cachedYearsActive;
  bool _cacheValid = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    final memories = await widget.memoryService.getMemories();
    if (!mounted) return;
    setState(() {
      _memories = memories;
      _isLoading = false;
      _invalidateCache();
    });
  }

  void _invalidateCache() {
    _cacheValid = false;
    _cachedOldestMemory = null;
    _cachedMonthlyStats = null;
    _cachedMaxCount = null;
    _cachedTopLocations = null;
    _cachedYearsActive = null;
  }

  Memory? get oldestMemory {
    if (!_cacheValid || _cachedOldestMemory == null) {
      if (_memories.isNotEmpty) {
        _cachedOldestMemory =
            _memories.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
      }
    }
    return _cachedOldestMemory;
  }

  Map<String, int> get monthlyStats {
    if (!_cacheValid || _cachedMonthlyStats == null) {
      _cachedMonthlyStats = <String, int>{};
      for (final memory in _memories) {
        final monthKey = DateFormat('MMM yyyy').format(memory.date);
        _cachedMonthlyStats![monthKey] =
            (_cachedMonthlyStats![monthKey] ?? 0) + 1;
      }
      _cacheValid = true;
    }
    return _cachedMonthlyStats!;
  }

  int get maxCount {
    if (_cachedMaxCount == null) {
      final stats = monthlyStats;
      _cachedMaxCount = stats.values.isEmpty
          ? 1
          : stats.values.reduce((a, b) => a > b ? a : b);
    }
    return _cachedMaxCount!;
  }

  List<MapEntry<String, int>> get topLocations {
    if (_cachedTopLocations == null) {
      final locationCounts = <String, int>{};
      for (final memory in _memories) {
        locationCounts[memory.location] =
            (locationCounts[memory.location] ?? 0) + 1;
      }

      final sorted = locationCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      _cachedTopLocations = sorted.take(5).toList();
    }
    return _cachedTopLocations!;
  }

  int get yearsActive {
    if (_cachedYearsActive == null) {
      if (_memories.isEmpty) {
        _cachedYearsActive = 0;
      } else {
        _cachedYearsActive = _memories.map((m) => m.date.year).toSet().length;
      }
    }
    return _cachedYearsActive!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFEDF2F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Memory Statistics',
                        style: AppTheme.titleStyle,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.3, end: 0),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: PremiumComponents.loadingIndicator(
                          message: 'Loading your memory insights...',
                        ),
                      )
                    : _buildStatsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    final totalMemories = _memories.length;
    final now = DateTime.now();
    final thisMonthMemories = _memories
        .where((m) => m.date.month == now.month && m.date.year == now.year)
        .length;
    final uniqueLocations = _memories.map((m) => m.location).toSet().length;
    final oldestMem = oldestMemory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumComponents.sectionHeader(
            title: 'Overview',
            subtitle: 'Your memory collection at a glance',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PremiumComponents.statsCard(
                  title: 'Total Memories',
                  value: totalMemories.toString(),
                  icon: Icons.favorite,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PremiumComponents.statsCard(
                  title: 'This Month',
                  value: thisMonthMemories.toString(),
                  icon: Icons.calendar_today,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PremiumComponents.statsCard(
                  title: 'Unique Places',
                  value: uniqueLocations.toString(),
                  icon: Icons.location_on,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PremiumComponents.statsCard(
                  title: 'Years Active',
                  value: yearsActive.toString(),
                  icon: Icons.timeline,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (_memories.isNotEmpty) ...[
            PremiumComponents.sectionHeader(
              title: 'Recent Activity',
              subtitle: 'Your latest memories',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Latest Memory',
                        style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _memories.last.title,
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM d, yyyy').format(_memories.last.date),
                    style: AppTheme.captionStyle,
                  ),
                  if (oldestMem != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: AppTheme.secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'First Memory',
                          style:
                              AppTheme.subheadingStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      oldestMem.title,
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(oldestMem.date),
                      style: AppTheme.captionStyle,
                    ),
                  ],
                ],
              ),
            )
                .animate(delay: const Duration(milliseconds: 200))
                .fadeIn()
                .slideY(begin: 0.3, end: 0),
          ],
          const SizedBox(height: 32),
          if (topLocations.isNotEmpty) ...[
            PremiumComponents.sectionHeader(
              title: 'Top Locations',
              subtitle: 'Places with the most memories',
            ),
            const SizedBox(height: 16),
            ...topLocations.map((location) => _buildLocationItem(location)),
          ],
          const SizedBox(height: 32),
          PremiumComponents.sectionHeader(
            title: 'Memory Timeline',
            subtitle: 'How your collection grew over time',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Memory Journey',
                      style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTimelineVisualization(),
              ],
            ),
          )
              .animate(delay: const Duration(milliseconds: 400))
              .fadeIn()
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLocationItem(MapEntry<String, int> location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.key,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${location.value} ${location.value == 1 ? 'memory' : 'memories'}',
                  style: AppTheme.captionStyle,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              location.value.toString(),
              style: AppTheme.captionStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * location.value))
        .fadeIn()
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildTimelineVisualization() {
    if (_memories.isEmpty) return const SizedBox();

    final stats = monthlyStats;
    final maxCountValue = maxCount;

    return Column(
      children: stats.entries.map((entry) {
        final percentage = entry.value / maxCountValue;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  entry.key,
                  style: AppTheme.captionStyle.copyWith(fontSize: 12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.value.toString(),
                style: AppTheme.captionStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
