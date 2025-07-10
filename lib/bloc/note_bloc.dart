// lib/bloc/note_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_offline_online/services/note_service.dart';
import '../models/note.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteService noteService;
  final Connectivity connectivity;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  NoteBloc(this.noteService, this.connectivity) : super(NoteInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<DeleteNote>(_onDeleteNote);
    on<SyncNotes>(_onSyncNotes);
    on<ClearAllNotes>(_onClearAllNotes);
    on<MarkNoteDone>(_onMarkNoteDone);

    // Listen to connectivity changes to auto-sync
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        add(SyncNotes());
      }
    });
  }

  Future<void> _onClearAllNotes(
      ClearAllNotes event, Emitter<NoteState> emit) async {
    await noteService.clearLocalNotes();
    emit(const NoteLoaded([]));
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final connected =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      if (connected) {
        try {
          await noteService.fetchFromServer(); // Optional & bisa gagal
        } catch (e) {
          print("⚠️ fetchFromServer failed, fallback to local only: $e");
        }
      }

      final localNotes = await noteService.getLocalNotes();
      emit(NoteLoaded(localNotes));
    } catch (e, st) {
      print("LOAD NOTE ERROR: $e\n$st");
      emit(const NoteError("Failed to load notes"));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NoteState> emit) async {
    await noteService.saveNoteOffline(event.note);
    add(LoadNotes());
    if ((await connectivity.checkConnectivity()) != ConnectivityResult.none) {
      add(SyncNotes());
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    await noteService.deleteNote(event.note);
    add(LoadNotes());
    if ((await connectivity.checkConnectivity()) != ConnectivityResult.none) {
      add(SyncNotes());
    }
  }

  Future<void> _onMarkNoteDone(
      MarkNoteDone event, Emitter<NoteState> emit) async {
    await noteService.updateNoteMarkDone(event.note);
    // add(LoadNotes());
    if ((await connectivity.checkConnectivity()) != ConnectivityResult.none) {
      add(SyncNotes());
    }
  }

  Future<void> _onSyncNotes(SyncNotes event, Emitter<NoteState> emit) async {
    try {
      await noteService.syncToServer();
      add(LoadNotes());
    } catch (_) {
      // silently ignore errors when syncing
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
