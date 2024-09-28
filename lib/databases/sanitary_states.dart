import 'package:sqflite/sqflite.dart';

class SanitaryStatesTable {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE sanitary_states (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ong_id INTEGER NOT NULL,
        site_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        animal_id INTEGER NOT NULL,
        label TEXT NOT NULL,
        description TEXT NOT NULL,
        corrective_action TEXT,  -- nullable
        cost REAL NOT NULL DEFAULT 0,  -- Le champ 'decimal' est traduit en 'REAL' dans SQLite
        temperature INTEGER,  -- nullable
        height INTEGER,  -- nullable
        weight INTEGER,  -- nullable
        slug TEXT NOT NULL,
        is_synced BOOLEAN NOT NULL DEFAULT 0,  -- Attribut pour la synchronisation
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }
}
