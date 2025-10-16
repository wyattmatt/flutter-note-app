import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/domain/models/note.dart';
import 'package:frontend/domain/repositories/note_repository.dart';
import 'package:frontend/ui/notes/bloc/note_bloc.dart';
import 'package:frontend/ui/notes/bloc/note_event.dart';
import 'package:frontend/ui/notes/bloc/note_state.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  late NoteBloc noteBloc;
  late MockNoteRepository mockRepository;

  setUp(() {
    mockRepository = MockNoteRepository();
    noteBloc = NoteBloc(repository: mockRepository);
  });

  tearDown(() {
    noteBloc.close();
  });

  group('NoteBloc Tests', () {
    final testNotes = [
      Note(id: 1, title: 'Note 1', body: 'Body 1'),
      Note(id: 2, title: 'Note 2', body: 'Body 2'),
    ];

    blocTest<NoteBloc, NoteState>(
      'emits [NoteLoading, NotesLoaded] when LoadNotes is added and succeeds',
      build: () {
        when(() => mockRepository.getNotes())
            .thenAnswer((_) async => testNotes);
        return noteBloc;
      },
      act: (bloc) => bloc.add(const LoadNotes()),
      expect: () => [
        const NoteLoading(),
        NotesLoaded(notes: testNotes),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'emits [NoteLoading, NoteError] when LoadNotes fails',
      build: () {
        when(() => mockRepository.getNotes())
            .thenThrow(Exception('Failed to load notes'));
        return noteBloc;
      },
      act: (bloc) => bloc.add(const LoadNotes()),
      expect: () => [
        const NoteLoading(),
        isA<NoteError>(),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'emits [NoteLoading, NoteDetailLoaded] when LoadNoteById succeeds',
      build: () {
        when(() => mockRepository.getNoteById(1))
            .thenAnswer((_) async => testNotes[0]);
        return noteBloc;
      },
      act: (bloc) => bloc.add(const LoadNoteById(1)),
      expect: () => [
        const NoteLoading(),
        NoteDetailLoaded(testNotes[0]),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'emits success and reloads when CreateNote succeeds',
      build: () {
        when(() => mockRepository.createNote('New Note', 'New Body'))
            .thenAnswer((_) async => testNotes[0]);
        when(() => mockRepository.getNotes())
            .thenAnswer((_) async => testNotes);
        return noteBloc;
      },
      act: (bloc) => bloc.add(const CreateNote(
        title: 'New Note',
        body: 'New Body',
      )),
      expect: () => [
        const NoteOperationSuccess('Note created successfully'),
        const NoteLoading(),
        NotesLoaded(notes: testNotes),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'emits success and reloads when UpdateNote succeeds',
      build: () {
        when(() => mockRepository.updateNote(1, 'Updated', 'Updated Body'))
            .thenAnswer((_) async => testNotes[0]);
        when(() => mockRepository.getNotes())
            .thenAnswer((_) async => testNotes);
        return noteBloc;
      },
      act: (bloc) => bloc.add(const UpdateNote(
        id: 1,
        title: 'Updated',
        body: 'Updated Body',
      )),
      expect: () => [
        const NoteOperationSuccess('Note updated successfully'),
        const NoteLoading(),
        NotesLoaded(notes: testNotes),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'emits success and reloads when DeleteNote succeeds',
      build: () {
        when(() => mockRepository.deleteNote(1)).thenAnswer((_) async => {});
        when(() => mockRepository.getNotes())
            .thenAnswer((_) async => testNotes);
        return noteBloc;
      },
      act: (bloc) => bloc.add(const DeleteNote(1)),
      expect: () => [
        const NoteOperationSuccess('Note deleted successfully'),
        const NoteLoading(),
        NotesLoaded(notes: testNotes),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'toggles selection mode',
      build: () => noteBloc,
      seed: () => NotesLoaded(notes: testNotes),
      act: (bloc) => bloc.add(const ToggleSelectionMode()),
      expect: () => [
        NotesLoaded(notes: testNotes, isSelectionMode: true, selectedNotes: []),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'selects all notes',
      build: () => noteBloc,
      seed: () => NotesLoaded(notes: testNotes),
      act: (bloc) => bloc.add(const SelectAllNotes()),
      expect: () => [
        NotesLoaded(
          notes: testNotes,
          isSelectionMode: true,
          selectedNotes: testNotes,
        ),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'toggles note selection',
      build: () => noteBloc,
      seed: () => NotesLoaded(notes: testNotes, isSelectionMode: true),
      act: (bloc) => bloc.add(ToggleNoteSelection(testNotes[0])),
      expect: () => [
        NotesLoaded(
          notes: testNotes,
          isSelectionMode: true,
          selectedNotes: [testNotes[0]],
        ),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'deletes multiple notes',
      build: () {
        when(() => mockRepository.deleteNotes(any()))
            .thenAnswer((_) async => {});
        when(() => mockRepository.getNotes()).thenAnswer((_) async => []);
        return noteBloc;
      },
      seed: () => NotesLoaded(
        notes: testNotes,
        isSelectionMode: true,
        selectedNotes: testNotes,
      ),
      act: (bloc) => bloc.add(DeleteMultipleNotes(testNotes)),
      expect: () => [
        const NoteOperationSuccess('Notes deleted successfully'),
        const NotesLoaded(notes: [], isSelectionMode: false, selectedNotes: []),
      ],
    );
  });
}
