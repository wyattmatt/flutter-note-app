import '../../domain/models/note.dart';

class NoteModel {
  final int id;
  final String title;
  final String body;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
    this.updatedAt,
  });

  factory NoteModel.fromDomain(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      body: note.body,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['ID'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'title': title,
      'body': body,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Note toDomain() {
    return Note(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'NoteModel(id: $id, title: $title, body: $body)';
}
