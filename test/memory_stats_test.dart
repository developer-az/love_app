import 'package:flutter_test/flutter_test.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/models/memory_stats.dart';

void main() {
  Memory memory({
    required String id,
    required String title,
    required DateTime date,
    String location = 'Paris',
    bool isFavorite = false,
  }) {
    return Memory(
      id: id,
      title: title,
      description: 'A story',
      imageUrl: 'https://example.com/$id.jpg',
      date: date,
      location: location,
      isFavorite: isFavorite,
    );
  }

  test('computes overview stats in one pass', () {
    final stats = MemoryStats.from(
      [
        memory(
          id: '1',
          title: 'Oldest',
          date: DateTime(2023, 5, 1),
          location: 'Rome',
        ),
        memory(
          id: '2',
          title: 'Newest added',
          date: DateTime(2024, 1, 20),
          location: 'Paris',
          isFavorite: true,
        ),
        memory(
          id: '3',
          title: 'This month',
          date: DateTime(2024, 1, 10),
          location: 'Paris',
        ),
      ],
      now: DateTime(2024, 1, 15),
    );

    expect(stats.total, 3);
    expect(stats.thisMonth, 2);
    expect(stats.uniqueLocations, 2);
    expect(stats.favoriteCount, 1);
    expect(stats.yearsActive, 2);
    expect(stats.oldest?.id, '1');
    expect(stats.latestAdded?.id, '3');
    expect(stats.topLocations.first.key, 'Paris');
    expect(stats.maxMonthlyCount, greaterThanOrEqualTo(2));
  });

  test('empty collection is cheap and stable', () {
    final stats = MemoryStats.from(const []);
    expect(stats.total, 0);
    expect(stats.maxMonthlyCount, 1);
    expect(stats.topLocations, isEmpty);
  });
}
