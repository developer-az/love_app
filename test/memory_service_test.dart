import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MemoryService service;

  Memory memory({
    required String id,
    String title = 'Title',
    String location = 'Paris',
    DateTime? date,
  }) {
    return Memory(
      id: id,
      title: title,
      description: 'A story',
      imageUrl: 'https://example.com/$id.jpg',
      date: date ?? DateTime(2024, 1, 1),
      location: location,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = MemoryService(prefs);
  });

  test('starts empty', () async {
    expect(await service.getMemories(), isEmpty);
  });

  test('adds, updates, and deletes memories', () async {
    await service.addMemory(memory(id: '1', title: 'One'));
    await service.addMemory(memory(id: '2', title: 'Two', location: 'Rome'));

    var memories = await service.getMemories();
    expect(memories.map((m) => m.id), ['1', '2']);

    await service
        .updateMemory(memory(id: '1', title: 'Updated', location: 'Lyon'));
    memories = await service.getMemories();
    expect(memories.first.title, 'Updated');
    expect(memories.first.location, 'Lyon');

    await service.deleteMemory('1');
    memories = await service.getMemories();
    expect(memories.map((m) => m.id), ['2']);
    expect(await service.getMemoryById('1'), isNull);
    expect((await service.getMemoryById('2'))?.title, 'Two');
  });

  test('ignores corrupt stored JSON instead of crashing', () async {
    SharedPreferences.setMockInitialValues({
      'memories': '{not-json',
    });
    final prefs = await SharedPreferences.getInstance();
    final brokenService = MemoryService(prefs);

    expect(await brokenService.getMemories(), isEmpty);
  });

  test('skips invalid records inside a valid list', () async {
    SharedPreferences.setMockInitialValues({
      'memories': json.encode([
        {
          'id': 'good',
          'title': 'Keep me',
          'description': 'd',
          'imageUrl': '',
          'date': '2024-01-01',
          'location': 'Home'
        },
        {'title': 'no id'},
        'string-item',
      ]),
    });
    final prefs = await SharedPreferences.getInstance();
    final mixedService = MemoryService(prefs);

    final memories = await mixedService.getMemories();
    expect(memories, hasLength(1));
    expect(memories.single.id, 'good');
  });

  test('keeps an in-memory cache across reads', () async {
    await service.addMemory(memory(id: '1', title: 'Cached'));
    final first = await service.getMemories();
    final second = await service.getMemories();

    expect(identical(first, second), isFalse);
    expect(first.single.title, 'Cached');
    expect(second.single.title, 'Cached');

    await service.updateMemory(memory(id: '1', title: 'Updated'));
    final third = await service.getMemories();
    expect(third.single.title, 'Updated');
  });

  test('parseMemoriesJson skips junk', () {
    expect(parseMemoriesJson('nope'), isEmpty);
    expect(
      parseMemoriesJson(json.encode([
        {
          'id': 'ok',
          'title': 'Keep',
          'description': 'd',
          'imageUrl': '',
          'date': '2024-01-01',
          'location': 'Home',
        },
      ])),
      hasLength(1),
    );
  });
}
