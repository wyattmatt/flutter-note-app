import '../../domain/models/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';
import '../services/note_api_service.dart';
import '../services/note_local_service.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteApiService apiService;
  final NoteLocalService localService;

  NoteRepositoryImpl({
    required this.apiService,
    required this.localService,
  });

  @override
  Future<List<Note>> getNotes() async {
    try {
      final apiNotes = await apiService.fetchNotes();

      await localService.saveNotes(apiNotes);

      return apiNotes.map((model) => model.toDomain()).toList();
    } catch (e) {
      print('API failed, using local storage: $e');
      final localNotes = localService.getAllNotes();
      return localNotes.map((model) => model.toDomain()).toList();
    }
  }

  @override
  Future<Note?> getNoteById(int id) async {
    try {
      final apiNote = await apiService.fetchNoteById(id);

      await localService.saveNote(apiNote);

      return apiNote.toDomain();
    } catch (e) {
      print('API failed, using local storage: $e');
      final localNote = localService.getNoteById(id);
      return localNote?.toDomain();
    }
  }

  @override
  Future<Note> createNote(String title, String body) async {
    try {
      final apiNote = await apiService.createNote(title, body);

      await localService.saveNote(apiNote);

      return apiNote.toDomain();
    } catch (e) {
      print('API failed, saving locally: $e');

      final localNotes = localService.getAllNotes();
      final tempId = localNotes.isEmpty
          ? -1
          : (localNotes.map((n) => n.id).reduce((a, b) => a < b ? a : b) - 1);

      final localNote = NoteModel(
        id: tempId,
        title: title,
        body: body,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await localService.saveNote(localNote);
      return localNote.toDomain();
    }
  }

  @override
  Future<Note> updateNote(int id, String title, String body) async {
    try {
      final apiNote = await apiService.updateNote(id, title, body);

      await localService.saveNote(apiNote);

      return apiNote.toDomain();
    } catch (e) {
      print('API failed, updating locally: $e');

      final localNote = NoteModel(
        id: id,
        title: title,
        body: body,
        updatedAt: DateTime.now(),
      );

      await localService.saveNote(localNote);
      return localNote.toDomain();
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    try {
      await apiService.deleteNote(id);

      await localService.deleteNote(id);
    } catch (e) {
      print('API failed, deleting locally: $e');
      await localService.deleteNote(id);
    }
  }

  @override
  Future<void> deleteNotes(List<int> ids) async {
    for (final id in ids) {
      await deleteNote(id);
    }
  }

  @override
  Future<void> clearLocalCache() async {
    await localService.clearAll();
  }
}
