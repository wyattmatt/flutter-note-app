import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/note.dart';
import '../../../injection.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import 'update_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NoteBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Note Detail'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateNoteScreen(note: note),
                  ),
                );

                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              if (note.createdAt != null) ...[
                Text(
                  'Created: ${_formatDate(note.createdAt!)}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5.0),
              ],
              if (note.updatedAt != null) ...[
                Text(
                  'Updated: ${_formatDate(note.updatedAt!)}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 15.0),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    note.body,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    final noteBloc = context.read<NoteBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              noteBloc.add(DeleteNote(note.id));
              Navigator.pop(dialogContext);
              Navigator.pop(
                  context, true);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
