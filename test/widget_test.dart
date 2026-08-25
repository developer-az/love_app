import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_special_app/main.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/screens/add_memory_screen.dart';
import 'package:my_special_app/screens/memory_detail_screen.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<MemoryService> createService({List<Memory> seed = const []}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = MemoryService(prefs);
    for (final memory in seed) {
      await service.addMemory(memory);
    }
    return service;
  }

  Memory sampleMemory() {
    return Memory(
      id: '1',
      title: 'Beach Day',
      description: 'Sunset picnic on the sand',
      imageUrl: 'https://example.com/beach.jpg',
      date: DateTime(2024, 7, 4),
      location: 'Santa Monica',
    );
  }

  testWidgets('empty home screen shows call to action', (tester) async {
    final service = await createService();
    await tester.pumpWidget(MySpecialApp(memoryService: service));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Cherished Memories'), findsOneWidget);
    expect(find.text('No memories yet'), findsOneWidget);
    expect(find.text('Add First Memory'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets);
  });

  testWidgets('home screen lists memories and opens details', (tester) async {
    final service = await createService(seed: [sampleMemory()]);
    await tester.pumpWidget(MySpecialApp(memoryService: service));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Beach Day'), findsOneWidget);
    expect(find.text('Santa Monica'), findsOneWidget);

    await tester.tap(find.text('Beach Day'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MemoryDetailScreen), findsOneWidget);
    expect(find.text('Sunset picnic on the sand'), findsOneWidget);
    expect(find.byTooltip('Delete memory'), findsOneWidget);
    expect(find.byTooltip('Edit memory'), findsOneWidget);
  });

  testWidgets('search filters memories without losing the query on rebuild',
      (tester) async {
    final service = await createService(seed: [
      sampleMemory(),
      Memory(
        id: '2',
        title: 'Mountain Hike',
        description: 'Alpine trail',
        imageUrl: 'https://example.com/hike.jpg',
        date: DateTime(2024, 8, 1),
        location: 'Rockies',
      ),
    ]);

    await tester.pumpWidget(MySpecialApp(memoryService: service));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await tester.enterText(find.byType(TextField), 'mountain');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Mountain Hike'), findsOneWidget);
    expect(find.text('Beach Day'), findsNothing);
  });

  testWidgets('add memory form validates required fields', (tester) async {
    final service = await createService();
    await tester.pumpWidget(
      MaterialApp(home: AddMemoryScreen(memoryService: service)),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.ensureVisible(find.text('Save Memory'));
    await tester.tap(find.text('Save Memory'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please enter a description'), findsOneWidget);
    expect(find.text('Please enter a location'), findsOneWidget);
    expect(await service.getMemories(), isEmpty);
  });
}
