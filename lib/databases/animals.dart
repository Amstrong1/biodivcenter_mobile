import 'package:sqflite/sqflite.dart';

class AnimalsTable {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE animals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        specie_id INTEGER NOT NULL,
        ong_id INTEGER NOT NULL,
        site_id INTEGER NOT NULL,
        pen_id INTEGER,
        name TEXT NOT NULL,
        weight TEXT NOT NULL,
        height TEXT NOT NULL,
        sex TEXT NOT NULL,
        birthdate TEXT NOT NULL,
        description TEXT NOT NULL,
        photo TEXT,
        state TEXT DEFAULT 'present',
        origin TEXT,
        parent_id INTEGER,
        slug TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        is_synced BOOLEAN NOT NULL DEFAULT 0,
        deleted_at TEXT
      )
    ''');
  }
}
