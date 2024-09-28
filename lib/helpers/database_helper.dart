import 'package:biodivcenter/databases/alimentations.dart';
import 'package:biodivcenter/databases/animals.dart';
import 'package:biodivcenter/databases/observations.dart';
import 'package:biodivcenter/databases/reproductions.dart';
import 'package:biodivcenter/databases/sanitary_states.dart';
import 'package:biodivcenter/databases/species.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('my_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await SpeciesTable.createTable(db);
    await AnimalsTable.createTable(db);
    await ObservationsTable.createTable(db);
    await ReproductionsTable.createTable(db);
    await AlimentationsTable.createTable(db);
    await SanitaryStatesTable.createTable(db);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> insertSpecies(Map<String, dynamic> speciesData) async {
    final db = await instance.database;
    await db.insert('species', speciesData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<dynamic>> getSpecies() async {
    final db = await instance.database;
    return await db.query('species');
  }

  Future<void> insertAnimal(Map<String, dynamic> animalData) async {
    final db = await instance.database;
    await db.insert('animals', animalData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertObservation(Map<String, dynamic> observationData) async {
    final db = await instance.database;
    await db.insert('observations', observationData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertReproduction(Map<String, dynamic> reproductionData) async {
    final db = await instance.database;
    await db.insert('reproductions', reproductionData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertAlimentation(Map<String, dynamic> alimentationData) async {
    final db = await instance.database;
    await db.insert('alimentations', alimentationData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertSanitaryState(
      Map<String, dynamic> sanitaryStateData) async {
    final db = await instance.database;
    await db.insert('sanitary_states', sanitaryStateData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllAnimals() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
        SELECT animals.*, species.french_name
        FROM animals
        JOIN species ON animals.specie_id = species.id
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getAnimals() async {
    final db = await instance.database;
    return await db.query('animals');
  }

  Future<List<Map<String, dynamic>>> getParents(int specieId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
        SELECT animals.id, animals.name
        FROM animals
        WHERE animals.specie_id = ?
    ''', [specieId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllObservations() async {
    final db = await instance.database;
    return await db.query('observations');
  }

  Future<List<Map<String, dynamic>>> getAllReproductions() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT reproductions.*, animals.name
      FROM reproductions
      JOIN animals ON reproductions.animal_id = animals.id
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllAlimentations() async {
    final db = await instance.database;

    // Effectuer une jointure entre alimentations et species sur specie_id
    final result = await db.rawQuery('''
    SELECT alimentations.*, species.french_name
    FROM alimentations
    JOIN species ON alimentations.specie_id = species.id
  ''');

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllSanitaryStates() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT sanitary_states.*, animals.name
      FROM sanitary_states
      JOIN animals ON sanitary_states.animal_id = animals.id
    ''');
  }

  Future<void> updateAnimal(Map<String, dynamic> animalData) async {
    final db = await instance.database;
    await db.update('animals', animalData,
        where: 'id = ?', whereArgs: [animalData['id']]);
  }

  Future<void> updateObservation(Map<String, dynamic> observationData) async {
    final db = await instance.database;
    await db.update('observations', observationData,
        where: 'id = ?', whereArgs: [observationData['id']]);
  }

  Future<void> updateReproduction(Map<String, dynamic> reproductionData) async {
    final db = await instance.database;
    await db.update('reproductions', reproductionData,
        where: 'id = ?', whereArgs: [reproductionData['id']]);
  }

  Future<void> updateAlimentation(Map<String, dynamic> alimentationData) async {
    final db = await instance.database;
    await db.update('alimentations', alimentationData,
        where: 'id = ?', whereArgs: [alimentationData['id']]);
  }

  Future<void> updateSanitaryState(
      Map<String, dynamic> sanitaryStateData) async {
    final db = await instance.database;
    await db.update('sanitary_states', sanitaryStateData,
        where: 'id = ?', whereArgs: [sanitaryStateData['id']]);
  }

  Future<void> deleteAnimal(int id) async {
    final db = await instance.database;
    final result = await db.query('animals', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty && result.first['is_synced'] == 0) {
      await db.delete('animals', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteObservation(int id) async {
    final db = await instance.database;
    final result =
        await db.query('observations', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty && result.first['is_synced'] == 0) {
      await db.delete('observations', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteReproduction(int id) async {
    final db = await instance.database;
    final result =
        await db.query('reproductions', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty && result.first['is_synced'] == 0) {
      await db.delete('reproductions', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteAlimentation(int id) async {
    final db = await instance.database;
    final result =
        await db.query('alimentations', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty && result.first['is_synced'] == 0) {
      await db.delete('alimentations', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteSanitaryState(int id) async {
    final db = await instance.database;
    final result =
        await db.query('sanitary_states', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty && result.first['is_synced'] == 0) {
      await db.delete('sanitary_states', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<List<Map<String, dynamic>>> getReproduction(int id) async {
    final db = await instance.database;
    return (await db.query(
      'reproductions',
      where: 'animal_id = ?',
      whereArgs: [id],
      orderBy: 'id DESC',
      limit: 1,
    ));
  }

  Future<List<Map<String, dynamic>>> getSanitaryState(int id) async {
    final db = await instance.database;
    return (await db.query(
      'sanitary_states',
      where: 'animal_id = ?',
      whereArgs: [id],
      orderBy: 'id DESC',
      limit: 1,
    ));
  }
}
