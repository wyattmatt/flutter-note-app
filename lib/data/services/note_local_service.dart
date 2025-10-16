import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NoteLocalService {
  static const String _notesKey = 'notes';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }

  Future<void> saveNote(NoteModel note) async {
    final notes = getAllNotes();
    final index = notes.indexWhere((n) => n.id == note.id);

    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }

    await saveNotes(notes);
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    final notesJson = notes.map((note) => note.toJson()).toList();
    final notesString = jsonEncode(notesJson);
    await _preferences.setString(_notesKey, notesString);
  }

  List<NoteModel> getAllNotes() {
    final notesString = _preferences.getString(_notesKey);

    if (notesString == null || notesString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> notesJson = jsonDecode(notesString);
      return notesJson.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing notes from SharedPreferences: $e');
      return [];
    }
  }

  NoteModel? getNoteById(int id) {
    final notes = getAllNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteNote(int id) async {
    final notes = getAllNotes();
    notes.removeWhere((note) => note.id == id);
    await saveNotes(notes);
  }

  Future<void> deleteNotes(List<int> ids) async {
    final notes = getAllNotes();
    notes.removeWhere((note) => ids.contains(note.id));
    await saveNotes(notes);
  }

  Future<void> clearAll() async {
    await _preferences.remove(_notesKey);
  }

  bool hasNote(int id) {
    return getNoteById(id) != null;
  }

  int get notesCount => getAllNotes().length;
}
