// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'bloc/note_bloc.dart';
import 'services/note_service.dart';
import 'pages/home_page.dart';

void main() {
  final noteService = NoteService();
  final connectivity = Connectivity();

  runApp(MyApp(noteService: noteService, connectivity: connectivity));
}

class MyApp extends StatelessWidget {
  final NoteService noteService;
  final Connectivity connectivity;

  const MyApp(
      {super.key, required this.noteService, required this.connectivity});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoteBloc(noteService, connectivity)..add(LoadNotes()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notes Offline Sync',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
