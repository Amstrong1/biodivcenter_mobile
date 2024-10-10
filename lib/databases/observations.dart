import 'package:sqflite/sqflite.dart';

class ObservationsTable {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE observations (
        id TEXT PRIMARY KEY,
        ong_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        site_id TEXT NOT NULL,
        subject TEXT NOT NULL,
        observation TEXT NOT NULL,
        photo TEXT,  -- nullable
        is_synced BOOLEAN NOT NULL DEFAULT 0,  -- Attribut pour la synchronisation
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    ''');
  }
}
