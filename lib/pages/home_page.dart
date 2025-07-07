// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import '../bloc/note_bloc.dart';
import '../models/note.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes Offline/Online"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Now',
            onPressed: () {
              context.read<NoteBloc>().add(SyncNotes());
            },
          ),
        ],
      ),
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: connected ? Colors.green : Colors.red,
                padding: const EdgeInsets.all(8),
                child: Text(
                  connected ? 'ONLINE' : 'OFFLINE',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(child: child),
            ],
          );
        },
        child: Column(
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              note.synced
                                  ? const Icon(Icons.cloud_done)
                                  : const Icon(Icons.cloud_off),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => context
                                    .read<NoteBloc>()
                                    .add(DeleteNote(note)),
                              ),
                            ],
                          ),
                          // trailing: note.synced
                          //     ? const Icon(Icons.cloud_done)
                          //     : const Icon(Icons.cloud_off),
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
      ),
    );
  }
}
