import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:nature_fan/models/message_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class MessageStorage extends Disposable {
  static const String _name = "Messages";

  final int _dbVersion = 1;

  final String _createTable = "CREATE TABLE $_name ("
      "message TEXT,"
      "timestamp INTEGER,"
      "PRIMARY KEY (timestamp)"
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

  Future<int> insertData(MessageModel data) {
    return _getDatabase().then(
      (db) => db
          .insert(
            _name,
            {"message": data.message, "timestamp": data.timestamp},
            conflictAlgorithm: ConflictAlgorithm.replace,
          )
          .catchError((error) {}),
    );
  }

  Future<List<MessageModel>> getData(int timestamp) {
    if (timestamp == 0) {
      return _getDatabase().then((db) => db.query(_name, limit: 5, orderBy: "timestamp DESC", )).then((result) => result.isNotEmpty
          ? result
              .map((data) => MessageModel.fromString(
                    message: data["message"] as String,
                    timestamp: data["timestamp"] as int,
                  ))
              .toList()
          : []);
    }

    return _getDatabase()
        .then((db) => db.query(_name, where: "timestamp < ?", whereArgs: [timestamp], limit: 2, orderBy: "timestamp DESC"))
        .then((result) => result.isNotEmpty
            ? result
                .map((data) => MessageModel.fromString(
                      message: data["message"] as String,
                      timestamp: data["timestamp"] as int,
                    ))
                .toList()
            : []);
  }

  @override
  void dispose() {
    _getDatabase().then((value) => value.close());
  }
}
