import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../injection.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';
import 'note_detail_screen.dart';
import 'add_note_screen.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NoteBloc>()..add(const LoadNotes()),
      child: const NoteListView(),
    );
  }
}

class NoteListView extends StatelessWidget {
  const NoteListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            final isSelectionMode =
                state is NotesLoaded && state.isSelectionMode;

            return AppBar(
              title: const Text('Note List'),
              centerTitle: false,
              automaticallyImplyLeading:
                  isSelectionMode,
              leading: isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        context.read<NoteBloc>().add(const ClearSelection());
                      },
                    )
                  : null,
              actions: [
                if (state is NotesLoaded)
                  if (!state.isSelectionMode)
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () {
                        context.read<NoteBloc>().add(const SelectAllNotes());
                      },
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        if (state.selectedNotes.isNotEmpty) {
                          _showDeleteConfirmation(
                              context, state.selectedNotes.length);
                        }
                      },
                    ),
              ],
            );
          },
        ),
      ),
      body: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is NoteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NoteLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(
                child: Text('No notes yet. Create your first note!'),
              );
            }
            return GestureDetector(
              onTap: () {
                if (state.isSelectionMode) {
                  context.read<NoteBloc>().add(const ClearSelection());
                }
              },
              child: ListView.builder(
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  final isSelected = state.selectedNotes.contains(note);

                  return ListTile(
                    title: Text(note.title),
                    subtitle: Text(
                      note.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: state.isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              context
                                  .read<NoteBloc>()
                                  .add(ToggleNoteSelection(note));
                            },
                          )
                        : null,
                    onTap: () async {
                      if (state.isSelectionMode) {
                        context.read<NoteBloc>().add(ToggleNoteSelection(note));
                      } else {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteDetailScreen(note: note),
                          ),
                        );

                        if (result == true && context.mounted) {
                          context.read<NoteBloc>().add(const LoadNotes());
                        }
                      }
                    },
                    onLongPress: () {
                      if (!state.isSelectionMode) {
                        context
                            .read<NoteBloc>()
                            .add(const ToggleSelectionMode());
                        context.read<NoteBloc>().add(ToggleNoteSelection(note));
                      }
                    },
                  );
                },
              ),
            );
          } else if (state is NoteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NoteBloc>().add(const LoadNotes());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Welcome to Notes App'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNoteScreen(),
            ),
          );
          if (context.mounted) {
            context.read<NoteBloc>().add(const LoadNotes());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Notes'),
        content: Text('Are you sure you want to delete $count note(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final bloc = context.read<NoteBloc>();
              final state = bloc.state;
              if (state is NotesLoaded) {
                bloc.add(DeleteMultipleNotes(state.selectedNotes));
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
