import 'package:sqflite/sqflite.dart';

class SpeciesTable {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE species (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scientific_name TEXT NOT NULL,
        french_name TEXT NOT NULL,
        status_uicn TEXT,
        status_cites TEXT,
        uicn_link TEXT,
        inaturalist_link TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    ''');
  }
}
