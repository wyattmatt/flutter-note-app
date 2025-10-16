import 'package:equatable/equatable.dart';
import '../../../domain/models/note.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {
  const LoadNotes();
}

class LoadNoteById extends NoteEvent {
  final int id;

  const LoadNoteById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateNote extends NoteEvent {
  final String title;
  final String body;

  const CreateNote({
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [title, body];
}

class UpdateNote extends NoteEvent {
  final int id;
  final String title;
  final String body;

  const UpdateNote({
    required this.id,
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [id, title, body];
}

class DeleteNote extends NoteEvent {
  final int id;

  const DeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteMultipleNotes extends NoteEvent {
  final List<Note> notes;

  const DeleteMultipleNotes(this.notes);

  @override
  List<Object?> get props => [notes];
}

class ToggleSelectionMode extends NoteEvent {
  const ToggleSelectionMode();
}

class ToggleNoteSelection extends NoteEvent {
  final Note note;

  const ToggleNoteSelection(this.note);

  @override
  List<Object?> get props => [note];
}

class SelectAllNotes extends NoteEvent {
  const SelectAllNotes();
}

class ClearSelection extends NoteEvent {
  const ClearSelection();
}
