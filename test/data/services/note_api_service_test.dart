import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:frontend/data/models/note_model.dart';
import 'package:frontend/data/services/note_api_service.dart';
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NoteApiService apiService;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    apiService = NoteApiService(client: mockClient);
  });

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('NoteApiService Tests', () {
    test('fetchNotes should return list of notes on success', () async {
      final mockResponse = [
        {'ID': 1, 'title': 'Note 1', 'body': 'Body 1'},
        {'ID': 2, 'title': 'Note 2', 'body': 'Body 2'},
      ];

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(mockResponse),
            200,
          ));

      final notes = await apiService.fetchNotes();

      expect(notes, isA<List<NoteModel>>());
      expect(notes.length, 2);
      expect(notes[0].title, 'Note 1');
      expect(notes[1].title, 'Note 2');
    });

    test('fetchNotes should throw exception on error', () async {
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('Error', 500));

      expect(() => apiService.fetchNotes(), throwsException);
    });

    test('fetchNoteById should return a single note', () async {
      final mockResponse = {'ID': 1, 'title': 'Test Note', 'body': 'Test Body'};

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(mockResponse),
            200,
          ));

      final note = await apiService.fetchNoteById(1);

      expect(note, isA<NoteModel>());
      expect(note.id, 1);
      expect(note.title, 'Test Note');
    });

    test('createNote should return created note', () async {
      final mockResponse = {'ID': 1, 'title': 'New Note', 'body': 'New Body'};

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(mockResponse),
            201,
          ));

      final note = await apiService.createNote('New Note', 'New Body');

      expect(note, isA<NoteModel>());
      expect(note.title, 'New Note');
      expect(note.body, 'New Body');
    });

    test('updateNote should return updated note', () async {
      final mockResponse = {
        'ID': 1,
        'title': 'Updated Note',
        'body': 'Updated Body'
      };

      when(() => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(mockResponse),
            200,
          ));

      final note =
          await apiService.updateNote(1, 'Updated Note', 'Updated Body');

      expect(note, isA<NoteModel>());
      expect(note.title, 'Updated Note');
    });

    test('deleteNote should complete successfully', () async {
      when(() => mockClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('', 204));

      await apiService.deleteNote(1);

      verify(() => mockClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('deleteNote should throw exception on error', () async {
      when(() => mockClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('Error', 500));

      expect(() => apiService.deleteNote(1), throwsException);
    });
  });
}
