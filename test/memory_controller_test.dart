import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/state/memory_controller.dart';
import 'package:my_special_app/utils/memory_dates.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Memory memory({
    required String id,
    String title = 'Title',
    String location = 'Paris',
    DateTime? date,
    bool isFavorite = false,
  }) {
    return Memory(
      id: id,
      title: title,
      description: 'A story',
      imageUrl: 'https://example.com/$id.jpg',
      date: date ?? DateTime(2024, 1, 1),
      location: location,
      isFavorite: isFavorite,
    );
  }

  Future<MemoryController> createController(List<Memory> seed) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = MemoryService(prefs);
    for (final item in seed) {
      await service.addMemory(item);
    }
    final controller = MemoryController(service);
    await controller.load();
    return controller;
  }

  test('search, sort, and favorites first', () async {
    final controller = await createController([
      memory(
          id: '1',
          title: 'Beach',
          location: 'Malibu',
          date: DateTime(2024, 7, 1)),
      memory(
        id: '2',
        title: 'Alpine',
        location: 'Rockies',
        date: DateTime(2023, 1, 1),
        isFavorite: true,
      ),
    ]);

    expect(controller.visibleMemories.first.title, 'Beach');

    controller.setSearchQuery('alpine');
    expect(controller.visibleMemories, hasLength(1));
    expect(controller.visibleMemories.single.title, 'Alpine');

    controller.setSearchQuery('');
    await controller.setSort(MemorySort.oldest);
    expect(controller.visibleMemories.first.title, 'Alpine');

    await controller.setSort(MemorySort.favoritesFirst);
    expect(controller.visibleMemories.first.isFavorite, isTrue);
    expect(controller.favoriteCount, 1);
  });

  test('undo delete restores the memory', () async {
    final controller = await createController([
      memory(id: '1', title: 'Keep'),
      memory(id: '2', title: 'Remove'),
    ]);

    await controller.delete(controller.memories.last);
    expect(controller.memories, hasLength(1));
    expect(controller.memories.single.title, 'Keep');

    expect(await controller.undoDelete(), isTrue);
    expect(controller.memories.map((m) => m.title),
        containsAll(['Keep', 'Remove']));
    expect(await controller.undoDelete(), isFalse);
  });

  test('layout and theme preferences persist', () async {
    final controller = await createController([]);
    await controller.setLayout(MemoryLayout.timeline);
    await controller.cycleThemeMode();
    expect(controller.layout, MemoryLayout.timeline);
    expect(controller.themeMode, ThemeMode.light);

    await controller.load();
    expect(controller.layout, MemoryLayout.timeline);
    expect(controller.themeMode, ThemeMode.light);
  });

  test('relative dates and grid columns', () {
    final now = DateTime(2026, 8, 25);
    expect(MemoryDates.relative(now, now: now), 'Today');
    expect(
      MemoryDates.relative(DateTime(2026, 8, 24), now: now),
      'Yesterday',
    );
    expect(MemoryDates.monthYear(DateTime(2024, 7, 4)), 'July 2024');
    expect(gridColumnsForWidth(400), 2);
    expect(gridColumnsForWidth(900), 3);
    expect(gridColumnsForWidth(1400), 4);
  });
}
