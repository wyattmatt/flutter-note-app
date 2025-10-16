import 'package:equatable/equatable.dart';
import '../../../domain/models/note.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {
  const NoteInitial();
}

class NoteLoading extends NoteState {
  const NoteLoading();
}

class NotesLoaded extends NoteState {
  final List<Note> notes;
  final bool isSelectionMode;
  final List<Note> selectedNotes;

  const NotesLoaded({
    required this.notes,
    this.isSelectionMode = false,
    this.selectedNotes = const [],
  });

  NotesLoaded copyWith({
    List<Note>? notes,
    bool? isSelectionMode,
    List<Note>? selectedNotes,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedNotes: selectedNotes ?? this.selectedNotes,
    );
  }

  @override
  List<Object?> get props => [notes, isSelectionMode, selectedNotes];
}

class NoteDetailLoaded extends NoteState {
  final Note note;

  const NoteDetailLoaded(this.note);

  @override
  List<Object?> get props => [note];
}

class NoteOperationSuccess extends NoteState {
  final String message;

  const NoteOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NoteError extends NoteState {
  final String message;

  const NoteError(this.message);

  @override
  List<Object?> get props => [message];
}
