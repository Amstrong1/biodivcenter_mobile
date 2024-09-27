import 'package:sqflite/sqflite.dart';

class AlimentationsTable {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE alimentations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        ong_id INTEGER NOT NULL,
        site_id INTEGER NOT NULL,
        specie_id INTEGER NOT NULL,
        age_range TEXT NOT NULL,
        food TEXT NOT NULL,
        frequency TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        cost REAL NOT NULL,  -- SQLite utilise REAL pour les décimales
        slug TEXT NOT NULL,
        is_synced BOOLEAN NOT NULL DEFAULT 0,  -- Attribut pour la synchronisation
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    ''');
  }
}
