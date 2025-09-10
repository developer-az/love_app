import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_components.dart';
import '../models/memory.dart';
import '../services/memory_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  final MemoryService memoryService;

  const StatsScreen({super.key, required this.memoryService});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Memory> _memories = [];
  bool _isLoading = true;

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
    });
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
              // Header
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
                            color: Colors.black.withOpacity(0.1),
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

              // Content
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
    final thisMonthMemories = _memories
        .where((m) =>
            m.date.month == DateTime.now().month &&
            m.date.year == DateTime.now().year)
        .length;
    final uniqueLocations = _memories.map((m) => m.location).toSet().length;
    final oldestMemory = _memories.isEmpty
        ? null
        : _memories.reduce((a, b) => a.date.isBefore(b.date) ? a : b);

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
                    style: AppTheme.captionStyle,
                  ),
                  if (oldestMemory != null) ...[
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
                          style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      oldestMemory!.title,
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(oldestMemory!.date),
                      style: AppTheme.captionStyle,
                    ),
                  ],
                ],
              ),
            ).animate(delay: const Duration(milliseconds: 200))
                .fadeIn()
                .slideY(begin: 0.3, end: 0),
          ],

          const SizedBox(height: 32),

          // Location Stats
          if (_getTopLocations().isNotEmpty) ...[
            PremiumComponents.sectionHeader(
              title: 'Top Locations',
              subtitle: 'Places with the most memories',
            ),
            const SizedBox(height: 16),
            ..._getTopLocations().map((location) => _buildLocationItem(location)),
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
          ).animate(delay: const Duration(milliseconds: 400))
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
    ).animate(delay: Duration(milliseconds: 100 * location.value))
        .fadeIn()
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildTimelineVisualization() {
    if (_memories.isEmpty) return const SizedBox();

    final monthlyStats = <String, int>{};
    for (final memory in _memories) {
      final monthKey = DateFormat('MMM yyyy').format(memory.date);
      monthlyStats[monthKey] = (monthlyStats[monthKey] ?? 0) + 1;
    }

    final maxCount = monthlyStats.values.isEmpty ? 1 : monthlyStats.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: monthlyStats.entries.map((entry) {
        final percentage = entry.value / maxCount;
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

  int _getYearsActive() {
    if (_memories.isEmpty) return 0;
    final years = _memories.map((m) => m.date.year).toSet();
    return years.length;
  }

  List<MapEntry<String, int>> _getTopLocations() {
    final locationCounts = <String, int>{};
    for (final memory in _memories) {
      locationCounts[memory.location] = (locationCounts[memory.location] ?? 0) + 1;
    }
    
    final sorted = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).toList();
  }
}