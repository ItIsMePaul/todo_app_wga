// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class AppDataBase {
  static const String DB_NAME = 'appDataBase.db';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, DB_NAME);
    final db = await databaseFactoryIo.openDatabase(dbPath);
    return db;
  }
}
