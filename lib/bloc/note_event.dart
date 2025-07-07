// lib/bloc/note_event.dart
part of 'note_bloc.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object> get props => [];
}

class LoadNotes extends NoteEvent {}

class ClearAllNotes extends NoteEvent {}

class AddNote extends NoteEvent {
  final Note note;
  const AddNote(this.note);
  @override
  List<Object> get props => [note];
}

class DeleteNote extends NoteEvent {
  final Note note;
  const DeleteNote(this.note);
  @override
  List<Object> get props => [note];
}

class MarkNoteDone extends NoteEvent {
  final Note note;
  const MarkNoteDone(this.note);
  @override
  List<Object> get props => [note];
}

class SyncNotes extends NoteEvent {}
