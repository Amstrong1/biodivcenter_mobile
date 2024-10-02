import 'package:sqflite/sqflite.dart';

class SpeciesTable {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE species (
        id TEXT PRIMARY KEY,
        french_name TEXT NOT NULL
      )
    ''');
  }
}
