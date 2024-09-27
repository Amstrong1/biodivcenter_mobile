import 'package:sqflite/sqflite.dart';

class ReproductionsTable {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE reproductions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ong_id INTEGER NOT NULL,
        site_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        animal_id INTEGER NOT NULL,
        phase TEXT NOT NULL,
        litter_size INTEGER NOT NULL,
        date TEXT NOT NULL,  -- SQLite ne prend pas en charge directement les dates, on utilise TEXT
        observation TEXT,  -- nullable
        slug TEXT NOT NULL,
        is_synced BOOLEAN NOT NULL DEFAULT 0,  -- Attribut pour la synchronisation
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    ''');
  }
}
