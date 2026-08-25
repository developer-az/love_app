import 'package:intl/intl.dart';
import 'package:my_special_app/models/memory.dart';

class MemoryStats {
  const MemoryStats({
    required this.total,
    required this.thisMonth,
    required this.uniqueLocations,
    required this.favoriteCount,
    required this.yearsActive,
    required this.maxMonthlyCount,
    required this.oldest,
    required this.latestAdded,
    required this.topLocations,
    required this.monthlyCounts,
  });

  final int total;
  final int thisMonth;
  final int uniqueLocations;
  final int favoriteCount;
  final int yearsActive;
  final int maxMonthlyCount;
  final Memory? oldest;
  final Memory? latestAdded;
  final List<MapEntry<String, int>> topLocations;
  final Map<String, int> monthlyCounts;

  factory MemoryStats.from(List<Memory> memories, {DateTime? now}) {
    if (memories.isEmpty) {
      return const MemoryStats(
        total: 0,
        thisMonth: 0,
        uniqueLocations: 0,
        favoriteCount: 0,
        yearsActive: 0,
        maxMonthlyCount: 1,
        oldest: null,
        latestAdded: null,
        topLocations: [],
        monthlyCounts: {},
      );
    }

    final current = now ?? DateTime.now();
    final monthFormat = DateFormat('MMM yyyy');
    Memory oldest = memories.first;
    final locationCounts = <String, int>{};
    final monthlyCounts = <String, int>{};
    final years = <int>{};
    var thisMonth = 0;
    var favoriteCount = 0;

    for (final memory in memories) {
      if (memory.date.isBefore(oldest.date)) oldest = memory;
      locationCounts[memory.location] =
          (locationCounts[memory.location] ?? 0) + 1;
      final monthKey = monthFormat.format(memory.date);
      monthlyCounts[monthKey] = (monthlyCounts[monthKey] ?? 0) + 1;
      years.add(memory.date.year);
      if (memory.date.month == current.month &&
          memory.date.year == current.year) {
        thisMonth += 1;
      }
      if (memory.isFavorite) favoriteCount += 1;
    }

    final topLocations = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxMonthly = monthlyCounts.values.isEmpty
        ? 1
        : monthlyCounts.values.reduce((a, b) => a > b ? a : b);

    return MemoryStats(
      total: memories.length,
      thisMonth: thisMonth,
      uniqueLocations: locationCounts.length,
      favoriteCount: favoriteCount,
      yearsActive: years.length,
      maxMonthlyCount: maxMonthly,
      oldest: oldest,
      latestAdded: memories.last,
      topLocations: topLocations.take(5).toList(growable: false),
      monthlyCounts: monthlyCounts,
    );
  }
}
