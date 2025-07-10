// lib/models/note.dart

class Note {
  final int? id;
  final String title;
  final String content;
  final bool markDone;
  final String? markedDoneAt; // waktu saat note ditandai done
  final bool synced;
  final String createdAt; // waktu saat note dibuat

  Note({
    this.id,
    required this.title,
    required this.content,
    this.markDone = false,
    this.markedDoneAt,
    this.synced = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'mark_done': markDone ? 1 : 0,
        'marked_done_at': markedDoneAt,
        'synced': synced ? 1 : 0,
        'created_at': createdAt,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        markDone: json['mark_done'] == true || json['mark_done'] == 1,
        synced: json['synced'] == true || json['synced'] == 1,
        markedDoneAt: json['marked_done_at'],
        createdAt: json['created_at'] ?? '', // fallback kosong kalau belum ada
      );

  Note copyWith({
    bool? markDone,
    String? markedDoneAt,
    bool? synced,
  }) {
    return Note(
      id: id,
      title: title,
      content: content,
      markDone: markDone ?? this.markDone,
      markedDoneAt: markedDoneAt ?? this.markedDoneAt,
      synced: synced ?? this.synced,
      createdAt: createdAt,
    );
  }
}
