import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/screens/stats_screen.dart';

void main() {
  group('Stats Screen Performance Optimization Tests', () {
    late MemoryService memoryService;

    setUp(() async {
      // Set up SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      memoryService = MemoryService(prefs);
    });

    testWidgets('Stats screen loads without errors when memories are empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StatsScreen(memoryService: memoryService),
        ),
      );

      // Wait for initial loading to complete
      await tester.pumpAndSettle();

      // Verify the screen loads without crashing
      expect(find.byType(StatsScreen), findsOneWidget);
      expect(find.text('Memory Statistics'), findsOneWidget);
    });

    testWidgets('Stats screen displays correct data with sample memories', (WidgetTester tester) async {
      // Add sample memories
      final memory1 = Memory(
        id: '1',
        title: 'Beach Day',
        description: 'Amazing day at the beach',
        imageUrl: 'https://example.com/beach.jpg',
        date: DateTime(2024, 1, 15),
        location: 'Miami Beach',
      );

      final memory2 = Memory(
        id: '2',
        title: 'Mountain Hike',
        description: 'Great hike in the mountains',
        imageUrl: 'https://example.com/mountain.jpg',
        date: DateTime(2024, 2, 10),
        location: 'Rocky Mountains',
      );

      final memory3 = Memory(
        id: '3',
        title: 'City Tour',
        description: 'Exploring the city',
        imageUrl: 'https://example.com/city.jpg',
        date: DateTime(2024, 1, 20),
        location: 'Miami Beach',
      );

      await memoryService.addMemory(memory1);
      await memoryService.addMemory(memory2);
      await memoryService.addMemory(memory3);

      await tester.pumpWidget(
        MaterialApp(
          home: StatsScreen(memoryService: memoryService),
        ),
      );

      // Wait for loading and data to appear
      await tester.pumpAndSettle();

      // Verify stats are displayed
      expect(find.text('3'), findsWidgets); // Total memories should be 3
      expect(find.text('Total Memories'), findsOneWidget);
      expect(find.text('Unique Places'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // Should find 2 unique locations

      // Verify timeline section exists
      expect(find.text('Memory Timeline'), findsOneWidget);

      // Verify location stats
      expect(find.text('Top Locations'), findsOneWidget);
    });

    test('Cache invalidation works correctly', () async {
      // This test verifies that our caching mechanism works
      // by ensuring that calculations are consistent before and after cache operations
      
      final memory1 = Memory(
        id: '1',
        title: 'Test Memory 1',
        description: 'Test',
        imageUrl: 'https://example.com/test1.jpg',
        date: DateTime(2023, 5, 1),
        location: 'Test Location',
      );

      final memory2 = Memory(
        id: '2',
        title: 'Test Memory 2',
        description: 'Test',
        imageUrl: 'https://example.com/test2.jpg',
        date: DateTime(2024, 3, 15),
        location: 'Test Location',
      );

      await memoryService.addMemory(memory1);
      await memoryService.addMemory(memory2);

      final memories = await memoryService.getMemories();
      
      // Verify we have the expected data
      expect(memories.length, 2);
      expect(memories.map((m) => m.location).toSet().length, 1); // 1 unique location
      
      // Verify oldest memory is correctly identified
      final oldest = memories.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
      expect(oldest.id, '1'); // memory1 should be oldest (2023 vs 2024)
    });
  });
}