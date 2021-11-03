import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:startup_namer/name_suggestion.dart';

class NameDatabase {
  static Future<void> _createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE favorite_names(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT UNIQUE,
        is_favorite BOOLEAN DEFAULT TRUE,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      join(await sql.getDatabasesPath(), 'startup_namer.db'),
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await _createTables(database);
      },
    );
  }

  static Future<int> addFavorite(String name) async {
    final db = await NameDatabase.db();

    final data = NameSuggestion(id: 0, name: name, isFavorite: true);
    final id = await db.insert('favorite_names', data.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.ignore);
    return id;
  }

  static Future<List<NameSuggestion>> getFavorites() async {
    final db = await NameDatabase.db();
    final List<Map<String, dynamic>> maps =
        await db.query('favorite_names', orderBy: 'name');

    return List.generate(
        maps.length,
        (i) => NameSuggestion(
            id: maps[i]['id'], name: maps[i]['name'], isFavorite: true));
  }

  static Future<NameSuggestion> getFavorite(int id) async {
    final db = await NameDatabase.db();
    final List<Map<String, dynamic>> maps = await db.query('favorite_names',
        where: "id = ?", whereArgs: [id], limit: 1);

    return List.generate(1, (i) => NameSuggestion(
        id: maps[i]['id'], name: maps[i]['name'], isFavorite: true)).first;
  }

  static Future<bool> isFavoriteByName(String name) async {
    final db = await NameDatabase.db();
    final List<Map<String, dynamic>> maps = await db.query('favorite_names',
        where: "name = ?", whereArgs: [name], limit: 1);

    return List.generate(maps.length, (i) => NameSuggestion(
        id: maps[i]['id'], name: maps[i]['name'], isFavorite: true)).isNotEmpty;
  }

  static Future<void> deleteFavorite(int id) async {
    final db = await NameDatabase.db();
    try {
      await db.delete("favorite_names", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteFavoriteByName(String name) async {
    final db = await NameDatabase.db();
    try {
      await db.delete("favorite_names", where: "name = ?", whereArgs: [name]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
