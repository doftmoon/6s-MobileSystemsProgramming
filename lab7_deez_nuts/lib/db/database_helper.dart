import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/developer.dart';

class DatabaseHelper {
  static const _databaseName = "developer_database.db";
  static const _databaseVersion = 1;

  static const table = 'developers';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnExperienceYears = 'experienceYears';
  static const columnSalary = 'salary';
  static const columnRole = 'role';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnExperienceYears INTEGER NOT NULL,
        $columnSalary REAL NOT NULL,
        $columnRole TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Developer developer) async {
    Database db = await database;
    return await db.insert(table, developer.toMap());
  }

  Future<List<Developer>> getAllDevelopers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Developer.fromMap(maps[i]);
    });
  }

  Future<List<Developer>> getDevelopersSortedBy(
    String column,
    bool ascending,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      orderBy: '$column ${ascending ? 'ASC' : 'DESC'}',
    );
    return List.generate(maps.length, (i) {
      return Developer.fromMap(maps[i]);
    });
  }

  Future<Developer?> getDeveloper(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Developer.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Developer developer) async {
    Database db = await database;
    return await db.update(
      table,
      developer.toMap(),
      where: '$columnId = ?',
      whereArgs: [developer.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
