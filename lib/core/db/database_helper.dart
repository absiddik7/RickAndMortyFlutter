import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/character_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'rick_morty.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // characters table stores cached API data
    await db.execute('''
      CREATE TABLE characters (
        id INTEGER PRIMARY KEY,
        name TEXT,
        status TEXT,
        species TEXT,
        type TEXT,
        gender TEXT,
        originName TEXT,
        locationName TEXT,
        image TEXT
      )
    ''');

    // favorites table stores favorite status
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY
      )
    ''');

    // overrides table stores user edits
    await db.execute('''
      CREATE TABLE overrides (
        id INTEGER PRIMARY KEY,
        name TEXT,
        status TEXT,
        species TEXT,
        type TEXT,
        gender TEXT,
        originName TEXT,
        locationName TEXT
      )
    ''');
  }

  // --- CRUD for Characters (Cache) ---
  Future<void> insertCharacters(List<Character> characters) async {
    final db = await database;
    Batch batch = db.batch();
    for (var char in characters) {
      batch.insert('characters', {
        'id': char.id,
        'name': char.name,
        'status': char.status,
        'species': char.species,
        'type': char.type,
        'gender': char.gender,
        'originName': char.originName,
        'locationName': char.locationName,
        'image': char.image,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedCharacters() async {
    final db = await database;
    return await db.query('characters');
  }

  // --- CRUD for Favorites ---
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    if (isFavorite) {
      await db.insert('favorites', {'id': id}, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<List<int>> getFavoriteIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) => maps[i]['id'] as int);
  }

  // --- CRUD for Overrides (Edits) ---
  Future<void> saveOverride(Character char) async {
    final db = await database;
    await db.insert('overrides', {
      'id': char.id,
      'name': char.name,
      'status': char.status,
      'species': char.species,
      'type': char.type,
      'gender': char.gender,
      'originName': char.originName,
      'locationName': char.locationName,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteOverride(int id) async {
    final db = await database;
    await db.delete('overrides', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getOverrides() async {
    final db = await database;
    return await db.query('overrides');
  }
}
