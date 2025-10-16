import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/note.dart';
import '../../../domain/repositories/note_repository.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repository;

  NoteBloc({required this.repository}) : super(const NoteInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<LoadNoteById>(_onLoadNoteById);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<DeleteMultipleNotes>(_onDeleteMultipleNotes);
    on<ToggleSelectionMode>(_onToggleSelectionMode);
    on<ToggleNoteSelection>(_onToggleNoteSelection);
    on<SelectAllNotes>(_onSelectAllNotes);
    on<ClearSelection>(_onClearSelection);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NoteState> emit) async {
    emit(const NoteLoading());
    try {
      final notes = await repository.getNotes();
      emit(NotesLoaded(notes: notes));
    } catch (e) {
      emit(NoteError('Failed to load notes: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNoteById(
      LoadNoteById event, Emitter<NoteState> emit) async {
    emit(const NoteLoading());
    try {
      final note = await repository.getNoteById(event.id);
      if (note != null) {
        emit(NoteDetailLoaded(note));
      } else {
        emit(const NoteError('Note not found'));
      }
    } catch (e) {
      emit(NoteError('Failed to load note: ${e.toString()}'));
    }
  }

  Future<void> _onCreateNote(CreateNote event, Emitter<NoteState> emit) async {
    try {
      await repository.createNote(event.title, event.body);
      emit(const NoteOperationSuccess('Note created successfully'));

      add(const LoadNotes());
    } catch (e) {
      emit(NoteError('Failed to create note: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NoteState> emit) async {
    try {
      await repository.updateNote(event.id, event.title, event.body);
      emit(const NoteOperationSuccess('Note updated successfully'));

      add(const LoadNotes());
    } catch (e) {
      emit(NoteError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    try {
      await repository.deleteNote(event.id);
      emit(const NoteOperationSuccess('Note deleted successfully'));

      add(const LoadNotes());
    } catch (e) {
      emit(NoteError('Failed to delete note: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMultipleNotes(
      DeleteMultipleNotes event, Emitter<NoteState> emit) async {
    final currentState = state;
    if (currentState is! NotesLoaded) return;

    try {
      final ids = event.notes.map((note) => note.id).toList();
      await repository.deleteNotes(ids);

      emit(const NoteOperationSuccess('Notes deleted successfully'));

      final notes = await repository.getNotes();
      emit(NotesLoaded(
          notes: notes, isSelectionMode: false, selectedNotes: const []));
    } catch (e) {
      emit(NoteError('Failed to delete notes: ${e.toString()}'));
    }
  }

  void _onToggleSelectionMode(
      ToggleSelectionMode event, Emitter<NoteState> emit) {
    final currentState = state;
    if (currentState is NotesLoaded) {
      emit(currentState.copyWith(
        isSelectionMode: !currentState.isSelectionMode,
        selectedNotes:
            !currentState.isSelectionMode ? [] : currentState.selectedNotes,
      ));
    }
  }

  void _onToggleNoteSelection(
      ToggleNoteSelection event, Emitter<NoteState> emit) {
    final currentState = state;
    if (currentState is NotesLoaded && currentState.isSelectionMode) {
      final selectedNotes = List<Note>.from(currentState.selectedNotes);

      if (selectedNotes.contains(event.note)) {
        selectedNotes.remove(event.note);
      } else {
        selectedNotes.add(event.note);
      }

      emit(currentState.copyWith(selectedNotes: selectedNotes));
    }
  }

  void _onSelectAllNotes(SelectAllNotes event, Emitter<NoteState> emit) {
    final currentState = state;
    if (currentState is NotesLoaded) {
      emit(currentState.copyWith(
        isSelectionMode: true,
        selectedNotes: List.from(currentState.notes),
      ));
    }
  }

  void _onClearSelection(ClearSelection event, Emitter<NoteState> emit) {
    final currentState = state;
    if (currentState is NotesLoaded) {
      emit(currentState.copyWith(
        isSelectionMode: false,
        selectedNotes: [],
      ));
    }
  }
}
