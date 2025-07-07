// lib/bloc/note_state.dart
part of 'note_bloc.dart';

abstract class NoteState extends Equatable {
  const NoteState();
  @override
  List<Object> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<Note> notes;
  const NoteLoaded(this.notes);
  @override
  List<Object> get props => [notes];
}

class NoteError extends NoteState {
  final String message;
  const NoteError(this.message);
  @override
  List<Object> get props => [message];
}
