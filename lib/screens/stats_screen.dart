import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/models/memory_stats.dart';
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
  MemoryStats _stats = MemoryStats.from(const []);
  bool _isLoading = true;

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
      _stats = MemoryStats.from(memories);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Statistics'),
      ),
      body: _isLoading
          ? Center(
              child: PremiumComponents.loadingIndicator(
                message: 'Loading your memory insights...',
              ),
            )
          : _buildStatsContent(),
    );
  }

  Widget _buildStatsContent() {
    final stats = _stats;
    final oldestMem = stats.oldest;
    final latest = stats.latestAdded;

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
                  value: stats.total.toString(),
                  icon: Icons.favorite,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PremiumComponents.statsCard(
                  title: 'This Month',
                  value: stats.thisMonth.toString(),
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
                  value: stats.uniqueLocations.toString(),
                  icon: Icons.location_on,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PremiumComponents.statsCard(
                  title: 'Years Active',
                  value: stats.yearsActive.toString(),
                  icon: Icons.timeline,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PremiumComponents.statsCard(
            title: 'Favorites',
            value: stats.favoriteCount.toString(),
            icon: Icons.favorite,
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(height: 32),
          if (latest != null) ...[
            PremiumComponents.sectionHeader(
              title: 'Recent Activity',
              subtitle: 'Your latest memories',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecorationOf(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Latest Memory',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    latest.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM d, yyyy').format(latest.date),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (oldestMem != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'First Memory',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      oldestMem.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(oldestMem.date),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (stats.topLocations.isNotEmpty) ...[
            PremiumComponents.sectionHeader(
              title: 'Top Locations',
              subtitle: 'Places with the most memories',
            ),
            const SizedBox(height: 16),
            ...stats.topLocations.map(_buildLocationItem),
          ],
          const SizedBox(height: 32),
          PremiumComponents.sectionHeader(
            title: 'Memory Timeline',
            subtitle: 'How your collection grew over time',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecorationOf(context),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Memory Journey',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTimelineVisualization(stats),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLocationItem(MapEntry<String, int> location) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecorationOf(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on,
              color: colorScheme.primary,
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${location.value} ${location.value == 1 ? 'memory' : 'memories'}',
                  style: Theme.of(context).textTheme.bodyMedium,
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineVisualization(MemoryStats stats) {
    if (_memories.isEmpty) return const SizedBox();

    final maxCountValue = stats.maxMonthlyCount;

    return Column(
      children: stats.monthlyCounts.entries.map((entry) {
        final percentage = entry.value / maxCountValue;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
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
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
