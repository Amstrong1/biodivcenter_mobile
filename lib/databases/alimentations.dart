import 'package:sqflite/sqflite.dart';

class AlimentationsTable {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE alimentations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        ong_id TEXT NOT NULL,
        site_id TEXT NOT NULL,
        specie_id TEXT NOT NULL,
        age_range TEXT NOT NULL,
        food TEXT NOT NULL,
        frequency TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        cost REAL NOT NULL,  -- SQLite utilise REAL pour les décimales
        is_synced BOOLEAN NOT NULL DEFAULT 0,  -- Attribut pour la synchronisation
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    ''');
  }
}
