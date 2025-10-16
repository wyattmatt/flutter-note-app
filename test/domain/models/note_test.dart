import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/models/note.dart';

void main() {
  group('Note Model Tests', () {
    test('Note should be created with correct properties', () {
      final note = Note(
        id: 1,
        title: 'Test Note',
        body: 'Test Body',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      expect(note.id, 1);
      expect(note.title, 'Test Note');
      expect(note.body, 'Test Body');
      expect(note.createdAt, DateTime(2024, 1, 1));
      expect(note.updatedAt, DateTime(2024, 1, 2));
    });

    test('Note copyWith should create new instance with updated values', () {
      final note = Note(
        id: 1,
        title: 'Original',
        body: 'Original Body',
      );

      final updated = note.copyWith(
        title: 'Updated',
      );

      expect(updated.id, 1);
      expect(updated.title, 'Updated');
      expect(updated.body, 'Original Body');
    });

    test('Two notes with same properties should be equal', () {
      final note1 = Note(
        id: 1,
        title: 'Test',
        body: 'Body',
      );

      final note2 = Note(
        id: 1,
        title: 'Test',
        body: 'Body',
      );

      expect(note1, equals(note2));
    });

    test('Two notes with different properties should not be equal', () {
      final note1 = Note(
        id: 1,
        title: 'Test',
        body: 'Body',
      );

      final note2 = Note(
        id: 2,
        title: 'Test',
        body: 'Body',
      );

      expect(note1, isNot(equals(note2)));
    });
  });
}
