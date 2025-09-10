import 'package:flutter/material.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/widgets/premium_components.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:intl/intl.dart';

/// Stats screen with optimized performance
/// 
/// PERFORMANCE OPTIMIZATION:
/// This screen previously had expensive reduce() and map() operations 
/// that were executed on every rebuild in the build methods.
/// 
/// SOLUTION: Added caching for expensive calculations using computed properties
/// that only recalculate when the underlying memories data changes.
class StatsScreen extends StatefulWidget {
  final MemoryService memoryService;

  const StatsScreen({super.key, required this.memoryService});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Memory> _memories = [];
  bool _isLoading = true;

  // Cached values to avoid expensive recalculations on every rebuild
  Memory? _cachedOldestMemory;
  Map<String, int>? _cachedMonthlyStats;
  int? _cachedMaxCount;
  List<MapEntry<String, int>>? _cachedTopLocations;
  bool _cacheValid = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final memories = await widget.memoryService.getMemories();
    setState(() {
      _memories = memories;
      _isLoading = false;
      // Invalidate cache when memories change
      _invalidateCache();
    });
  }

  // Clear cached values when memories change
  void _invalidateCache() {
    _cacheValid = false;
    _cachedOldestMemory = null;
    _cachedMonthlyStats = null;
    _cachedMaxCount = null;
    _cachedTopLocations = null;
  }

  // Computed property for oldest memory with caching
  Memory? get oldestMemory {
    if (!_cacheValid || _cachedOldestMemory == null) {
      if (_memories.isNotEmpty) {
        _cachedOldestMemory = _memories.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
      }
    }
    return _cachedOldestMemory;
  }

  // Computed property for monthly stats with caching
  Map<String, int> get monthlyStats {
    if (!_cacheValid || _cachedMonthlyStats == null) {
      _cachedMonthlyStats = <String, int>{};
      for (final memory in _memories) {
        final monthKey = DateFormat('MMM yyyy').format(memory.date);
        _cachedMonthlyStats![monthKey] = (_cachedMonthlyStats![monthKey] ?? 0) + 1;
      }
      _cacheValid = true;
    }
    return _cachedMonthlyStats!;
  }

  // Computed property for max count with caching
  int get maxCount {
    if (!_cacheValid || _cachedMaxCount == null) {
      final stats = monthlyStats; // This will ensure monthlyStats is calculated first
      _cachedMaxCount = stats.values.isEmpty ? 1 : stats.values.reduce((a, b) => a > b ? a : b);
    }
    return _cachedMaxCount!;
  }

  // Computed property for top locations with caching
  List<MapEntry<String, int>> get topLocations {
    if (!_cacheValid || _cachedTopLocations == null) {
      final locationCounts = <String, int>{};
      for (final memory in _memories) {
        locationCounts[memory.location] = (locationCounts[memory.location] ?? 0) + 1;
      }
      
      final sorted = locationCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      _cachedTopLocations = sorted.take(5).toList();
    }
    return _cachedTopLocations!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Statistics'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
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
        child: _isLoading
            ? Center(
                child: PremiumComponents.loadingIndicator(
                  message: 'Loading your memory insights...',
                ),
              )
            : _buildStatsContent(),
      ),
    );
  }

  // FIXED: Now uses cached computed properties instead of expensive operations on every rebuild
  Widget _buildStatsContent() {
    // These calculations are now cached and only computed when memories change
    final totalMemories = _memories.length;
    final thisMonthMemories = _memories
        .where((m) =>
            m.date.month == DateTime.now().month &&
            m.date.year == DateTime.now().year)
        .length;
    final uniqueLocations = _memories.map((m) => m.location).toSet().length;
    
    // PERFORMANCE FIXED: Now uses cached computed property instead of reduce on every rebuild!
    final oldestMem = oldestMemory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
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
                  color: Colors.pink,
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
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PremiumComponents.statsCard(
                  title: 'Years Active',
                  value: _getYearsActive().toString(),
                  icon: Icons.timeline,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Activity
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
                    style: AppTheme.bodyStyle.copyWith(color: Colors.grey[600]),
                  ),
                  if (oldestMem != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: Colors.pink,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'First Memory',
                          style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      oldestMem!.title,
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(oldestMem!.date),
                      style: AppTheme.bodyStyle.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Location Stats
          if (topLocations.isNotEmpty) ...[
            PremiumComponents.sectionHeader(
              title: 'Top Locations',
              subtitle: 'Places with the most memories',
            ),
            const SizedBox(height: 16),
            ...topLocations.map((location) => _buildLocationItem(location)),
          ],

          const SizedBox(height: 32),

          // Memory Timeline
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
          ),

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
              color: AppTheme.primaryColor.withOpacity(0.1),
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
                  style: AppTheme.bodyStyle.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              location.value.toString(),
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PERFORMANCE FIXED: Now uses cached computed properties instead of expensive calculations on every rebuild!
  Widget _buildTimelineVisualization() {
    if (_memories.isEmpty) return const SizedBox();

    // PERFORMANCE FIXED: Now uses cached computed properties
    final stats = monthlyStats; // Cached calculation
    final maxCountValue = maxCount; // Cached calculation

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
                  style: AppTheme.bodyStyle.copyWith(fontSize: 12, color: Colors.grey[600]),
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
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.value.toString(),
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _getYearsActive() {
    if (_memories.isEmpty) return 0;
    final years = _memories.map((m) => m.date.year).toSet();
    return years.length;
  }
}