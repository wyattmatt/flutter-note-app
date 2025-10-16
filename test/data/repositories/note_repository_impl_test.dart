import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/data/models/note_model.dart';
import 'package:frontend/data/repositories/note_repository_impl.dart';
import 'package:frontend/data/services/note_api_service.dart';
import 'package:frontend/data/services/note_local_service.dart';
import 'package:frontend/domain/models/note.dart';

class MockNoteApiService extends Mock implements NoteApiService {}

class MockNoteLocalService extends Mock implements NoteLocalService {}

class FakeNoteModel extends Fake implements NoteModel {}

void main() {
  late NoteRepositoryImpl repository;
  late MockNoteApiService mockApiService;
  late MockNoteLocalService mockLocalService;

  setUpAll(() {
    registerFallbackValue(FakeNoteModel());
  });

  setUp(() {
    mockApiService = MockNoteApiService();
    mockLocalService = MockNoteLocalService();
    repository = NoteRepositoryImpl(
      apiService: mockApiService,
      localService: mockLocalService,
    );
  });

  group('NoteRepositoryImpl Tests', () {
    final testNoteModels = [
      NoteModel(id: 1, title: 'Note 1', body: 'Body 1'),
      NoteModel(id: 2, title: 'Note 2', body: 'Body 2'),
    ];

    test('getNotes should return notes from API and save to local', () async {
      when(() => mockApiService.fetchNotes())
          .thenAnswer((_) async => testNoteModels);
      when(() => mockLocalService.saveNotes(any())).thenAnswer((_) async => {});

      final notes = await repository.getNotes();

      expect(notes, isA<List<Note>>());
      expect(notes.length, 2);
      verify(() => mockApiService.fetchNotes()).called(1);
      verify(() => mockLocalService.saveNotes(testNoteModels)).called(1);
    });

    test('getNotes should fallback to local on API failure', () async {
      when(() => mockApiService.fetchNotes()).thenThrow(Exception('API Error'));
      when(() => mockLocalService.getAllNotes()).thenReturn(testNoteModels);

      final notes = await repository.getNotes();

      expect(notes, isA<List<Note>>());
      expect(notes.length, 2);
      verify(() => mockLocalService.getAllNotes()).called(1);
    });

    test('getNoteById should return note from API and save to local', () async {
      when(() => mockApiService.fetchNoteById(1))
          .thenAnswer((_) async => testNoteModels[0]);
      when(() => mockLocalService.saveNote(any())).thenAnswer((_) async => {});

      final note = await repository.getNoteById(1);

      expect(note, isA<Note>());
      expect(note?.id, 1);
      verify(() => mockApiService.fetchNoteById(1)).called(1);
      verify(() => mockLocalService.saveNote(testNoteModels[0])).called(1);
    });

    test('getNoteById should fallback to local on API failure', () async {
      when(() => mockApiService.fetchNoteById(1))
          .thenThrow(Exception('API Error'));
      when(() => mockLocalService.getNoteById(1)).thenReturn(testNoteModels[0]);

      final note = await repository.getNoteById(1);

      expect(note, isA<Note>());
      expect(note?.id, 1);
      verify(() => mockLocalService.getNoteById(1)).called(1);
    });

    test('createNote should create via API and save to local', () async {
      when(() => mockApiService.createNote('New', 'Body'))
          .thenAnswer((_) async => testNoteModels[0]);
      when(() => mockLocalService.saveNote(any())).thenAnswer((_) async => {});

      final note = await repository.createNote('New', 'Body');

      expect(note, isA<Note>());
      verify(() => mockApiService.createNote('New', 'Body')).called(1);
      verify(() => mockLocalService.saveNote(any())).called(1);
    });

    test('createNote should create locally on API failure', () async {
      when(() => mockApiService.createNote('New', 'Body'))
          .thenThrow(Exception('API Error'));
      when(() => mockLocalService.getAllNotes()).thenReturn([]);
      when(() => mockLocalService.saveNote(any())).thenAnswer((_) async => {});

      final note = await repository.createNote('New', 'Body');

      expect(note, isA<Note>());
      expect(note.title, 'New');
      expect(note.body, 'Body');
      verify(() => mockLocalService.saveNote(any())).called(1);
    });

    test('updateNote should update via API and save to local', () async {
      when(() => mockApiService.updateNote(1, 'Updated', 'Body'))
          .thenAnswer((_) async => testNoteModels[0]);
      when(() => mockLocalService.saveNote(any())).thenAnswer((_) async => {});

      final note = await repository.updateNote(1, 'Updated', 'Body');

      expect(note, isA<Note>());
      verify(() => mockApiService.updateNote(1, 'Updated', 'Body')).called(1);
      verify(() => mockLocalService.saveNote(any())).called(1);
    });

    test('deleteNote should delete from API and local', () async {
      when(() => mockApiService.deleteNote(1)).thenAnswer((_) async => {});
      when(() => mockLocalService.deleteNote(1)).thenAnswer((_) async => {});

      await repository.deleteNote(1);

      verify(() => mockApiService.deleteNote(1)).called(1);
      verify(() => mockLocalService.deleteNote(1)).called(1);
    });

    test('deleteNote should delete locally on API failure', () async {
      when(() => mockApiService.deleteNote(1))
          .thenThrow(Exception('API Error'));
      when(() => mockLocalService.deleteNote(1)).thenAnswer((_) async => {});

      await repository.deleteNote(1);

      verify(() => mockLocalService.deleteNote(1)).called(1);
    });

    test('deleteNotes should delete multiple notes', () async {
      when(() => mockApiService.deleteNote(any())).thenAnswer((_) async => {});
      when(() => mockLocalService.deleteNote(any()))
          .thenAnswer((_) async => {});

      await repository.deleteNotes([1, 2]);

      verify(() => mockApiService.deleteNote(1)).called(1);
      verify(() => mockApiService.deleteNote(2)).called(1);
    });

    test('clearLocalCache should clear all local data', () async {
      when(() => mockLocalService.clearAll()).thenAnswer((_) async => {});

      await repository.clearLocalCache();

      verify(() => mockLocalService.clearAll()).called(1);
    });
  });
}
