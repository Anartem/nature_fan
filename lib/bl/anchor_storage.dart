import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/models/anchor_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AnchorStorage extends Disposable {
  static const String _name = "Anchors";

  final int _dbVersion = 1;

  final String _createTable = "CREATE TABLE $_name ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "anchor TEXT"
      ")";

  Database? _database;

  Future<Database> _getDatabase() async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, _name);

    return openDatabase(
      path,
      version: _dbVersion,
      onOpen: (db) => {},
      onCreate: (db, version) => db.execute(_createTable),
    );
  }

  Future<int> insertData(AnchorModel data) {
    return _getDatabase().then(
      (db) => db
          .insert(
            _name,
            {"anchor": data.position.join(" ")},
            conflictAlgorithm: ConflictAlgorithm.replace,
          )
          .catchError((error) {}),
    );
  }

  Future<List<AnchorModel>> getData() {
    return _getDatabase().then((db) => db.query(_name, limit: 5, orderBy: "id DESC")).then((result) =>
        result.isNotEmpty
            ? result
                .map((data) =>
                    AnchorModel(position: (data["anchor"] as String).split(" ").map((e) => double.parse(e)).toList()))
                .toList()
            : []);
  }

  @override
  void dispose() {
    _getDatabase().then((value) => value.close());
  }
}
