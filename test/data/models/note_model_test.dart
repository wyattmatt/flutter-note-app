import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/models/note_model.dart';
import 'package:frontend/domain/models/note.dart';

void main() {
  group('NoteModel Tests', () {
    test('fromJson should create NoteModel from JSON with ID field', () {
      final json = {
        'ID': 1,
        'title': 'Test Note',
        'body': 'Test Body',
      };

      final model = NoteModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Test Note');
      expect(model.body, 'Test Body');
    });

    test('fromJson should create NoteModel from JSON with lowercase id', () {
      final json = {
        'id': 1,
        'title': 'Test Note',
        'body': 'Test Body',
      };

      final model = NoteModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Test Note');
      expect(model.body, 'Test Body');
    });

    test('fromJson should handle dates correctly', () {
      final json = {
        'ID': 1,
        'title': 'Test',
        'body': 'Body',
        'createdAt': '2024-01-01T10:00:00.000Z',
        'updatedAt': '2024-01-02T10:00:00.000Z',
      };

      final model = NoteModel.fromJson(json);

      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('toJson should convert NoteModel to JSON', () {
      final model = NoteModel(
        id: 1,
        title: 'Test Note',
        body: 'Test Body',
      );

      final json = model.toJson();

      expect(json['ID'], 1);
      expect(json['title'], 'Test Note');
      expect(json['body'], 'Test Body');
    });

    test('toDomain should convert NoteModel to Note', () {
      final model = NoteModel(
        id: 1,
        title: 'Test Note',
        body: 'Test Body',
      );

      final note = model.toDomain();

      expect(note, isA<Note>());
      expect(note.id, 1);
      expect(note.title, 'Test Note');
      expect(note.body, 'Test Body');
    });

    test('fromDomain should convert Note to NoteModel', () {
      final note = Note(
        id: 1,
        title: 'Test Note',
        body: 'Test Body',
      );

      final model = NoteModel.fromDomain(note);

      expect(model.id, 1);
      expect(model.title, 'Test Note');
      expect(model.body, 'Test Body');
    });
  });
}
