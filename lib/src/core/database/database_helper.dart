import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final String path = join(await getDatabasesPath(), 'alex_test_app.db');
    return await openDatabase(
      path,
      version: 4, // Increased version to add userId field
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop existing tables
    await db.execute('DROP TABLE IF EXISTS map_pins');
    await db.execute('DROP TABLE IF EXISTS user');
    await db.execute('DROP TABLE IF EXISTS sync_queue');

    // Recreate tables with new schema
    await _createTables(db);
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
    CREATE TABLE user(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    await db.execute('''
    CREATE TABLE map_pins (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      label TEXT NOT NULL,
      comments TEXT,
      firebaseId TEXT,
      userId TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
''');

    await db.execute('''
    CREATE TABLE sync_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      data TEXT NOT NULL,
      createdAt TEXT NOT NULL
    )
''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
