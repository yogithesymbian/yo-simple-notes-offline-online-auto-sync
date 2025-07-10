// lib/services/note_service.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class NoteService {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: 3, // << upgrade dari versi 1 ke 2
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT,
          mark_done INTEGER,
          marked_done_at TEXT,
          synced INTEGER,
          created_at TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Kolom baru yang perlu ditambahkan di versi 2
          await db.execute("ALTER TABLE notes ADD COLUMN marked_done_at TEXT");
          await db.execute("ALTER TABLE notes ADD COLUMN created_at TEXT");

          // Optional: isi default created_at agar tidak kosong (pakai now)
          final now = DateTime.now().toUtc().toIso8601String();
          await db.rawUpdate("UPDATE notes SET created_at = ?", [now]);
        }
      },
    );
  }

  Future<void> clearLocalNotes() async {
    final database = await db;
    await database.delete('notes');
  }

  Future<void> saveNoteOffline(Note note) async {
    final database = await db;
    await database.insert('notes', note.toJson());
  }

  Future<void> updateNoteMarkDone(Note note) async {
    final database = await db;
    await database.update(
      'notes',
      note
          .copyWith(
            synced: false,
            markDone: !note.markDone,
            markedDoneAt: DateTime.now().toUtc().toIso8601String(),
          )
          .toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(Note note) async {
    final database = await db;
    await database.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<List<Note>> getLocalNotes() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('notes');
    return List.generate(maps.length, (i) => Note.fromJson(maps[i]));
  }

  Future<void> syncToServer() async {
    final database = await db;
    final unsynced =
        await database.query('notes', where: 'synced = ?', whereArgs: [0]);

    for (final row in unsynced) {
      final note = Note.fromJson(row);

      try {
        final response = await http.post(
          Uri.parse('http://192.168.43.5:8080/notes/offline-process'),
          headers: {
            'Content-Type': 'application/json',
            // TODO just test replace with your actual JWT token
            'Authorization':
                'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTIzODY2MjIsInVzZXJfaWQiOjV9.BcLpnSySn8W64aOBXbE4l-7k0lQyY1YmCzHPbCQPgr8',
          },
          body: jsonEncode({
            'id': note.id,
            'title': note.title,
            'content': note.content,
            'mark_done': note.markDone,
            'created_at': note.createdAt,
            'mark_done_at': note.markedDoneAt,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print("✅ Success to sync note ID ${note.id}: ${response.statusCode}");
          await database.update(
            'notes',
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [note.id],
          );
        } else {
          await database.update(
            'notes',
            {'synced': 0},
            where: 'id = ?',
            whereArgs: [note.id],
          );
          print("❌ Failed to sync note ID ${note.id}: ${response.statusCode}");
          print("[syncToServer] Body: ${response.body}");
        }
      } catch (e, st) {
        print("🔥 Exception syncing note ID ${note.id}: $e");
        print(st);
      }
    }
  }

  Future<void> fetchFromServer() async {
    print('🚀 fetchFromServer');
    final database = await db;

    final response = await http.get(
      Uri.parse('http://192.168.43.5:8080/notes'),
      headers: {
        'Content-Type': 'application/json',
        // TODO just test replace with your actual JWT token
        'Authorization':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTIzODY2MjIsInVzZXJfaWQiOjV9.BcLpnSySn8W64aOBXbE4l-7k0lQyY1YmCzHPbCQPgr8',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      for (var item in data) {
        final note = Note.fromJson(item);
        final noteJson = note.toJson();

        // Check if the note already exists in local DB
        final existing = await database.query(
          'notes',
          where: 'id = ?',
          whereArgs: [note.id],
        );

        if (existing.isEmpty) {
          await database.insert('notes', noteJson);
          print("✅ Success server to local ${note.id}: ${response.statusCode}");
        } else {
          print(
              "✅ Success update local by server ${note.id}: ${response.statusCode}");
          await database.update(
            'notes',
            noteJson,
            where: 'id = ?',
            whereArgs: [note.id],
          );
        }
      }
    } else {
      print("❌ Failed to fetch notes: ${response.statusCode}");
      print("[fetchFromServer] Body: ${response.body}");
      throw Exception('Failed to fetch notes');
    }
  }
}
