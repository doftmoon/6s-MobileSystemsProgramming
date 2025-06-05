import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'worker_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Workers table
    await db.execute('''
      CREATE TABLE workers(
        id TEXT PRIMARY KEY,
        workName TEXT NOT NULL,
        name TEXT NOT NULL,
        rate REAL NOT NULL,
        discount REAL NOT NULL,
        payment REAL NOT NULL,
        syncStatus TEXT NOT NULL
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        itemId TEXT NOT NULL,
        favoritedAt TEXT NOT NULL,
        itemName TEXT,
        syncStatus TEXT NOT NULL
      )
    ''');

    // Pending operations table to track offline changes
    await db.execute('''
      CREATE TABLE pending_operations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        collection TEXT NOT NULL,
        documentId TEXT,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  // Workers CRUD operations
  Future<List<Map<String, dynamic>>> getWorkers() async {
    final db = await database;
    return await db.query('workers');
  }

  Future<String> insertWorker(Map<String, dynamic> worker, String id) async {
    final db = await database;
    worker['id'] = id;
    worker['syncStatus'] = 'pending_upload';
    await db.insert('workers', worker);
    return id;
  }

  Future<void> updateWorker(String id, Map<String, dynamic> worker) async {
    final db = await database;
    worker['syncStatus'] = 'pending_upload';
    await db.update(
      'workers',
      worker,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteWorker(String id) async {
    final db = await database;
    await db.delete(
      'workers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markWorkerSynced(String id) async {
    final db = await database;
    await db.update(
      'workers',
      {'syncStatus': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Favorites CRUD operations
  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final db = await database;
    return await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<String> insertFavorite(Map<String, dynamic> favorite, String id) async {
    final db = await database;
    favorite['id'] = id;
    favorite['syncStatus'] = 'pending_upload';
    await db.insert('favorites', favorite);
    return id;
  }

  Future<void> deleteFavorite(String userId, String itemId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'userId = ? AND itemId = ?',
      whereArgs: [userId, itemId],
    );
  }

  Future<void> markFavoriteSynced(String id) async {
    final db = await database;
    await db.update(
      'favorites',
      {'syncStatus': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Pending operations management
  Future<void> addPendingOperation(String operation, String collection, String? documentId, String data) async {
    final db = await database;
    await db.insert('pending_operations', {
      'operation': operation,
      'collection': collection,
      'documentId': documentId,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final db = await database;
    return await db.query(
      'pending_operations',
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> deletePendingOperation(int id) async {
    final db = await database;
    await db.delete(
      'pending_operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 