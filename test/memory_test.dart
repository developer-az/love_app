import 'package:flutter_test/flutter_test.dart';
import 'package:my_special_app/models/memory.dart';

void main() {
  group('Memory', () {
    final sample = Memory(
      id: 'abc',
      title: 'Beach Day',
      description: 'Sunset picnic',
      imageUrl: 'https://example.com/photo.jpg',
      date: DateTime(2024, 7, 4),
      location: 'Santa Monica',
    );

    test('serializes to and from JSON', () {
      final restored = Memory.fromJson(sample.toJson());

      expect(restored.id, sample.id);
      expect(restored.title, sample.title);
      expect(restored.description, sample.description);
      expect(restored.imageUrl, sample.imageUrl);
      expect(restored.date, sample.date);
      expect(restored.location, sample.location);
    });

    test('matchesQuery searches title, description, and location', () {
      expect(sample.matchesQuery('beach'), isTrue);
      expect(sample.matchesQuery('PICNIC'), isTrue);
      expect(sample.matchesQuery('monica'), isTrue);
      expect(sample.matchesQuery('paris'), isFalse);
      expect(sample.matchesQuery(''), isTrue);
      expect(sample.matchesQuery('   '), isTrue);
    });

    test('copyWith only replaces provided fields', () {
      final copy = sample.copyWith(title: 'New Title', location: 'Malibu');
      expect(copy.id, sample.id);
      expect(copy.title, 'New Title');
      expect(copy.location, 'Malibu');
      expect(copy.description, sample.description);
    });

    test('tryFromJson skips malformed records', () {
      expect(Memory.tryFromJson(null), isNull);
      expect(Memory.tryFromJson('nope'), isNull);
      expect(Memory.tryFromJson({'title': 'Missing id'}), isNull);
      expect(
        Memory.tryFromJson({
          'id': 42,
          'title': 'Numeric id',
          'description': 'ok',
          'imageUrl': '',
          'date': 'not-a-date',
          'location': 'Home',
        }),
        isNotNull,
      );
    });
  });
}
