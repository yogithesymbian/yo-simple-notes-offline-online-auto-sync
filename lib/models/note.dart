class Note {
  final int? id;
  final String title;
  final String content;
  final bool markDone;
  final bool synced;

  Note(
      {this.id,
      required this.title,
      required this.content,
      this.markDone = false,
      this.synced = false});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'mark_done': markDone ? 1 : 0,
        'synced': synced ? 1 : 0,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        markDone: json['mark_done'] == 1,
        synced: json['synced'] == 1,
      );

  Note copyWith({bool? markDone, bool? synced}) => Note(
        id: id,
        title: title,
        content: content,
        markDone: markDone ?? this.markDone,
        synced: synced ?? this.synced,
      );
}
