// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/note_bloc.dart';
import '../models/note.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Notes Offline/Online")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final note = Note(
                        title: titleController.text,
                        content: contentController.text);
                    context.read<NoteBloc>().add(AddNote(note));
                    titleController.clear();
                    contentController.clear();
                  },
                  child: const Text("Add Note"),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NoteLoaded) {
                  return ListView.builder(
                    itemCount: state.notes.length,
                    itemBuilder: (context, index) {
                      final note = state.notes[index];
                      return ListTile(
                        title: Text(note.title),
                        subtitle: Text(note.content),
                        leading: Checkbox(
                          value: note.markDone,
                          onChanged: (_) {
                            context.read<NoteBloc>().add(MarkNoteDone(note));
                          },
                        ),
                        trailing: note.synced
                            ? const Icon(Icons.cloud_done)
                            : const Icon(Icons.cloud_off),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("Failed to load notes"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
