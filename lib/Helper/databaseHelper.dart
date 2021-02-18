import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor(); //Singleton Constructor
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static final _dbName = 'mangaDb';
  static final _dbVersion = 1;
  static final id = 'id';
  static final url = 'url';
  static final title = 'title';
  static final queuedchapterUrl = 'queuedchapterUrl';
  static final queuedchapterNo = 'queuedchapterNo';
  static final queuedchapterIndex = 'queuedchapterIndex';
  //static final latestchapterUrl = 'latestchapterUrl';
  static final latestchapterNo = 'latestchapterNo';
  static final imageUrl = 'imageUrl';
  static final dateAdded = 'dateAdded';

  //Initialize the database
  static Database _database;
  Future<Database> get database async {
    if (_database == null) {
      _database = await _initiateDatabase();
    }
    return _database;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path,
        version: _dbVersion,
        onCreate:
            _onCreate); //sqflite will automatically initailize and open the database
  }

  Future _onCreate(Database db, int version) async {
    db.execute('''
    CREATE TABLE favourites(
      $id INTEGER PRIMARY KEY,
      $title TEXT,
      $url TEXT,
      $imageUrl TEXT,
      $dateAdded TEXT,
      $latestchapterNo TEXT)
    ''');
    db.execute('''
    CREATE TABLE queue(
      $id INTEGER PRIMARY KEY,
      $title TEXT,
      $url TEXT,
      $imageUrl TEXT,
      $dateAdded TEXT,
      $queuedchapterNo TEXT,
      $queuedchapterUrl TEXT,
      $queuedchapterIndex INTEGER)
    ''');
  }

  Future<int> insert(Map<String, dynamic> row, String tableName) async {
    Database db = await instance
        .database; //gets the database obj from the current instance
    return await db.insert(
        tableName, row); //returns the id of the row we just inserted
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    Database db = await instance.database;
    return await db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> rowQuery(
      String t, String tableName) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(tableName, where: '$title=?', whereArgs: [t]);
  }

  Future<int> delete(int idToDelete, String tableName) async {
    Database db = await instance.database;
    return await db.delete(tableName, where: '$id=?', whereArgs: [idToDelete]);
  }

  Future<int> update(
      int idToUpdate,
      String tableName,
      String title,
      String url,
      String imageUrl,
      String dateAdded,
      String queuedchapterNo,
      String queuedchapterUrl,
      int queuedchapterIndex) async {
    Database db = await DatabaseHelper.instance.database;

    Map<String, dynamic> row = {
      DatabaseHelper.title: title,
      DatabaseHelper.url: url,
      DatabaseHelper.imageUrl: imageUrl,
      DatabaseHelper.dateAdded: dateAdded,
      DatabaseHelper.queuedchapterNo: queuedchapterNo,
      DatabaseHelper.queuedchapterUrl: queuedchapterUrl,
      DatabaseHelper.queuedchapterIndex: queuedchapterIndex,
    };
    int updateCount = await db.update(tableName, row,
        where: '${DatabaseHelper.id} = ?', whereArgs: [idToUpdate]);
    return updateCount;
  }
}
