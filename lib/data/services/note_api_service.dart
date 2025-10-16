import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note_model.dart';

class NoteApiService {
  final String baseUrl;
  final http.Client client;

  NoteApiService({
    this.baseUrl = 'http://localhost:8080',
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<NoteModel>> fetchNotes() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => NoteModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<NoteModel> fetchNoteById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return NoteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<NoteModel> createNote(String title, String body) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'body': body,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return NoteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<NoteModel> updateNote(int id, String title, String body) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'body': body,
        }),
      );

      if (response.statusCode == 200) {
        return NoteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  void dispose() {
    client.close();
  }
}
