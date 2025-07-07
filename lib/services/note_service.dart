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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            mark_done INTEGER,
            synced INTEGER
          )
        ''');
      },
    );
  }

  Future<void> saveNoteOffline(Note note) async {
    final database = await db;
    await database.insert('notes', note.toJson());
  }

  Future<void> updateNoteMarkDone(Note note) async {
    final database = await db;
    await database.update(
      'notes',
      note.copyWith(markDone: !note.markDone, synced: false).toJson(),
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
          Uri.parse('http://192.168.43.5:8080/notes'),
          headers: {
            'Content-Type': 'application/json',
            // TODO just test replace with your actual JWT token
            'Authorization':
                'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTIxMjY5ODMsInVzZXJfaWQiOjV9.22_l3t1lCIKEpSryTdrqLtNFXVVRFQJE0SOstlgNRJs',
          },
          body: jsonEncode({
            'title': note.title,
            'content': note.content,
            'mark_done': note.markDone,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await database.update(
            'notes',
            {'synced': 1},
            where: 'id = ?',
            whereArgs: [note.id],
          );
        } else {
          print("❌ Failed to sync note ID ${note.id}: ${response.statusCode}");
          print("Body: ${response.body}");
        }
      } catch (e, st) {
        print("🔥 Exception syncing note ID ${note.id}: $e");
        print(st);
      }
    }
  }

  Future<void> fetchFromServer() async {
    final response = await http.get(
      Uri.parse('http://192.168.43.5:8080/notes'),
      headers: {
        'Content-Type': 'application/json',
        // TODO just test replace with your actual JWT token
        'Authorization':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTIxMjY5ODMsInVzZXJfaWQiOjV9.22_l3t1lCIKEpSryTdrqLtNFXVVRFQJE0SOstlgNRJs',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> remoteNotes = jsonDecode(response.body);
      final dbClient = await db;

      for (final json in remoteNotes) {
        final note = Note.fromJson(json);
        await dbClient.insert(
          'notes',
          note.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } else {
      print("❌ Failed to fetch notes: ${response.statusCode}");
      print("Body: ${response.body}");
    }
  }
}
