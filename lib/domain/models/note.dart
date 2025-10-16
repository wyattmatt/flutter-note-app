import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int id;
  final String title;
  final String body;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
    this.updatedAt,
  });

  Note copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, body, createdAt, updatedAt];

  @override
  String toString() => 'Note(id: $id, title: $title, body: $body)';
}
