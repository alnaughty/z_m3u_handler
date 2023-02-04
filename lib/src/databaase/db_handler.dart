import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/src/models/categorized_m3u_data.dart';
import '../models/m3u_entry.dart';

class DBHandler {
  final RegExp season = RegExp(
    r"((\b(s|S))(\d+))|((\b(season|SEASON|Season))((\d+)|( \d+)))",
    multiLine: true,
  );

  final RegExp episode = RegExp(
      r"((\b(e|E))(\d+))|((\b(episode|EPISODE|Episode|ep|EP|Ep))((\d+)|( \d+)))");
  final epAndSe = RegExp(
    r"\b(s|S|SEASON|season|Season)(\d+(E|e|EPISODE|episode|Episode(\d+)))",
  );
  DBHandler._pr();
  static final DBHandler _instance = DBHandler._pr();
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDB();
  static DBHandler get instance => _instance;

  Future<Database> _initDB() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, "default.db");

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
        'CREATE TABLE entries(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, url TEXT NOT NULL, duration INTEGER NULL, image TEXT NULL, category_id INT NOT NULL, type INT NOT NULL, FOREIGN KEY (category_id) REFERENCES categories (id))');
  }

  Future<void> clearTable() async {
    final Database db = await instance.database;
    await db.delete("categories");
    await db.delete("entries");
    await DefaultCacheManager().emptyCache();
    // await db.rawDelete("DELETE * FROM categories");
    // await db.rawDelete("DELETE * FROM entries");
  }

  Future<int> addEntry(int categoryID, M3uEntry entry) async {
    try {
      final Database db = await instance.database;
      Map<String, dynamic> data = entry.toJson();
      data.addAll({
        "category_id": categoryID,
      });
      if (entry.link.isNotEmpty) {
        int type = entry.link.getType;
        if (type == 0 || type == 1) {
          print("LIVE FOUND!");
        }
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
      return -1;
    }
  }

  Future<CategorizedM3UData?> getData() async {
    try {
      final Database db = await instance.database;
      final List data = await db.rawQuery("SELECT *  FROM categories");
      List<M3uEntry> series = [];
      List<M3uEntry> movies = [];
      List<M3uEntry> live = [];
      List<M3uEntry> allData = [];
      for (Map<String, dynamic> datum in data) {
        final List e = await db.rawQuery(
          "SELECT *  FROM entries WHERE category_id = ${datum['id']}",
        );
        final List<M3uEntry> entry = e
            .map(
              (e) => M3uEntry.fromEntryInformation(
                link: e['url'],
                information: EntryInfo(
                  attributes: {
                    "tvg-logo": e['image'],
                    "group-title": datum['name'],
                    "title-clean": e['name']
                        .toString()
                        .replaceAll(season, "")
                        .replaceAll(episode, "")
                        .replaceAll(epAndSe, "")
                        .trim(),
                  },
                  duration: e['duration'],
                  title: e['name'],
                ),
                type: e['type'] ?? 0,
              ),
            )
            .toList();
        allData += entry;
        // series = __data.categorizeType(3);
      }
      print(allData);
    } catch (e) {
      print("ERROR FETCHING DATA FROM DB");
      return null;
    }
  }

  // List<M3uEntry> categorizeBy(List<M3uEntry> data, int type) {
  //   return data.where((element) => element.type == type).toList();
  //   // final Map<String, List<M3uEntry>> series =
  //   //     folder(data.where((element) => element.type.toInt() == 3).toList());
  //   // final Map<String, List<M3uEntry>> movies = folder(
  //   //   data.where((element) => element.type.toInt() == 2).toList(),
  //   // );
  //   // final Map<String, List<M3uEntry>> lives = folder(
  //   //   data
  //   //       .where((element) =>
  //   //           element.type.toInt() != 2 && element.type.toInt() != 3)
  //   //       .toList(),
  //   // );
  //   // return [
  //   //   series,
  //   //   movies,
  //   //   lives,
  //   // ];
  // }

  // Future<void> categorizeData() async {
  //   final Database db = await instance.database;
  //   final List data = await db.rawQuery("SELECT *  FROM categories");
  //   final List<M3UCategorized> ff = [];
  //   for (Map<String, dynamic> datum in data) {
  // final List e = await db.rawQuery(
  //     "SELECT *  FROM entries WHERE category_id = ${datum['id']}");
  // List<M3uEntry> _data = e
  //     .map(
  //       (e) => M3uEntry.fromEntryInformation(
  //         link: e['url'],
  //         information: EntryInfo(
  //           attributes: {
  //             "tvg-logo": e['image'],
  //             "group-title": datum['name'],
  //             "title-clean": e['name']
  //                 .toString()
  //                 .replaceAll(season, "")
  //                 .replaceAll(episode, "")
  //                 .replaceAll(epAndSe, "")
  //                 .trim(),
  //           },
  //           duration: e['duration'],
  //           title: e['name'],
  //         ),
  //         type: e['type'] ?? 0,
  //       ),
  //     )
  //     .toList();
  //     List<Map<String, List<M3uEntry>>> _dd = categorizeBy(_data);
  //     final List<Series> moviesCategorized = _dd[1]
  //         .entries
  //         .map((e) => Series(
  //             title: e.key,
  //             entries: e.value
  //                 .map((e) => M3uParsedEntry.fromJson(e.toJson()))
  //                 .toList()))
  //         .toList();

  //     final List<Series> seriesCategorized = _dd[0]
  //         .entries
  //         .map((e) => Series(
  //             title: e.key,
  //             entries: e.value
  //                 .map((e) => M3uParsedEntry.fromJson(e.toJson()))
  //                 .toList()))
  //         .toList();
  //     // final List<M3uParsedEntry> liveCategorized = _dd[2]
  //     //     .entries
  //     //     .map((e) => M3uParsedEntry.fromJson(e.toJson()))
  //     //     .toList();
  //     ff.add(
  //       M3UCategorized.withData(
  //         title: datum['name'],
  //         series: seriesCategorized,
  //         movies: moviesCategorized,
  //         lives: _data.where((element) => element.type.toInt() <= 1).toList(),
  //       ),
  //     );
  //   }
  //   print("NOT EMPTY LIVE: ${ff.where((element) => element.lives.isNotEmpty)}");
  //   _mainData.populateAll(ff);
  //   return;
  // }
}
