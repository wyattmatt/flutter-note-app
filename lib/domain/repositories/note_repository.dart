import '../models/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();

  Future<Note?> getNoteById(int id);

  Future<Note> createNote(String title, String body);

  Future<Note> updateNote(int id, String title, String body);

  Future<void> deleteNote(int id);

  Future<void> deleteNotes(List<int> ids);

  Future<void> clearLocalCache();
}
