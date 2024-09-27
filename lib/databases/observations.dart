import 'package:sqflite/sqflite.dart';

class ObservationsTable {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE observations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ong_id INTEGER NOT NULL,
        site_id INTEGER NOT NULL,
        subject TEXT NOT NULL,
        observation TEXT NOT NULL,
        photo TEXT,  -- nullable
        slug TEXT NOT NULL,
        is_synced BOOLEAN NOT NULL DEFAULT 0,  -- Attribut pour la synchronisation
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    ''');
  }
}
