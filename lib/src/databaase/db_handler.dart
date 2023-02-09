import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/src/helpers/db_regx.dart';
import 'package:z_m3u_handler/src/models/categorized_m3u_data.dart';
import '../models/m3u_entry.dart';

class DBHandler with DBRegX {
  DBHandler._pr();
  static final DBHandler _instance = DBHandler._pr();
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDB();
  static DBHandler get instance => _instance;

  Future<Database> _initDB() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, "m3u.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
    await db.execute(
        'CREATE TABLE entries(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, link TEXT NOT NULL, duration INTEGER NULL, image TEXT NULL, category_id INT NOT NULL, type INT NOT NULL, FOREIGN KEY (category_id) REFERENCES categories (id))');
  }

  Future<void> clearTable() async {
    final Database db = await instance.database;
    await db.delete("categories");
    await db.delete("entries");
    await DefaultCacheManager().emptyCache();
    // await db.rawDelete("DELETE * FROM categories");
    // await db.rawDelete("DELETE * FROM entries");
  }

  Future<int> addEntry(int catId, M3uEntry entry) async {
    try {
      final Database db = await instance.database;
      Map<String, dynamic> data = entry.toDBObj();
      data.addAll({
        "category_id": catId,
      });
      if (entry.link.isNotEmpty) {
        int type = entry.link.getType;
        // if (type == 0 || type == 1) {
        //   print("LIVE FOUND!");
        // } else if (type == 2) {
        //   print("SERIES FOUND!");
        // } else {
        //   print("MOVIE FOUND!");
        // }
        data.addAll({
          "type": type,
        });
      } else {
        data.addAll({"type": 0});
      }
      return await db.insert(
        "entries",
        data,
      );
    } catch (e) {
      print("ERROR APPENDING DATA");
      return -1;
    }
  }

  Future<int> addCategory(String name) async {
    try {
      final Database db = await instance.database;
      return await db.insert("categories", {
        "name": name,
      });
    } catch (e) {
      return -1;
    }
  }

  Future<CategorizedM3UData?> getData() async {
    try {
      final Database db = await instance.database;
      final List data = await db.rawQuery("SELECT *  FROM categories");
      List<M3uEntry> allData = [];
      for (Map<String, dynamic> datum in data) {
        final List e = await db.rawQuery(
          "SELECT *  FROM entries WHERE category_id = ${datum['id']}",
        );
        final List<M3uEntry> entry = e
            .map(
              (e) => M3uEntry.fromEntryInformation(
                link: e['link'],
                information: EntryInfo(
                  attributes: {
                    "tvg-logo": e['image'],
                    "group-title": datum['title'],
                    "title-clean": e['title']
                        .toString()
                        .replaceAll(season, "")
                        .replaceAll(episode, "")
                        .replaceAll(epAndSe, "")
                        .trim(),
                  },
                  duration: e['duration'],
                  title: e['title'],
                ),
                type: e['type'] ?? 0,
              ),
            )
            .toList();
        allData += entry;
        // series = __data.categorizeType(3);
      }
      return CategorizedM3UData(
        live: allData.where((element) => element.type <= 1).toList(),
        movies: allData.where((element) => element.type == 2).toList(),
        series: allData.where((element) => element.type == 3).toList(),
      );
    } catch (e) {
      print("ERROR FETCHING DATA FROM DB");
      return null;
    }
  }
}
