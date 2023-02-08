library z_m3u_handler;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/src/databaase/db_handler.dart';
import 'package:z_m3u_handler/src/helpers/file_downloader.dart';
import 'package:z_m3u_handler/src/helpers/parser.dart';
import 'package:z_m3u_handler/src/models/categorized_m3u_data.dart';
import 'package:z_m3u_handler/src/models/m3u_entry.dart';

export 'package:z_m3u_handler/src/models/m3u_entry.dart';
export 'package:z_m3u_handler/src/models/categorized_m3u_data.dart';

class ZM3UHandler {
  ZM3UHandler._pr();
  static final ZM3UHandler _instance = ZM3UHandler._pr();
  static ZM3UHandler get instance => _instance;
  Future<CategorizedM3UData?> network(
      String url, ValueChanged<double> progressCallback,
      {VoidCallback? onFinished}) async {
    try {
      final File? _file = await _downloader.downloadFile(
        url,
        progressCallback,
      );
      if (_file == null) return null;
      final String data = await _file.readAsString();
      await _file.delete();
      final List<M3uEntry> _res = await _parse(data);
      await _extract(_res);
      if (onFinished != null) {
        onFinished();
      }
      return await savedData;
    } catch (e, s) {
      return null;
    }
  }

  Future<CategorizedM3UData?> file(
      File file, ValueChanged<double> progressCallback,
      {VoidCallback? onFinished}) async {
    try {
      final String data = await file.readAsString();
      final List<M3uEntry> _res = await _parse(data);
      await _extract(_res);
      if (onFinished != null) {
        onFinished();
      }
      return await savedData;
    } catch (e) {
      return null;
    }
  }

  Future<void> _extract(
    List<M3uEntry> data,
  ) async {
    try {
      assert(data.isNotEmpty, "DATA RETURNED IS EMPTY");
      await _dbHandler.clearTable();
      Map<String, List<M3uEntry>> _cats =
          data.categorize(needle: "group-title");

      for (MapEntry mentry in _cats.entries) {
        int catId = await _dbHandler.addCategory(mentry.key);

        final List<M3uEntry> _genEnts = (mentry.value as List<M3uEntry>);
        print(_genEnts);
        for (M3uEntry entry in _genEnts) {
          await _dbHandler
              .addEntry(
                catId,
                entry,
              )
              .then((value) => null);
        }
      }

      return;
    } catch (e, s) {
      return;
    }
  }

  Future<CategorizedM3UData?> get savedData async {
    try {
      return await _dbHandler.getData();
    } catch (e) {
      return null;
    }
  }

  static final FileDownloader _downloader = FileDownloader();

  static final M3uParser _parser = M3uParser.instance;
  static final DBHandler _dbHandler = DBHandler.instance;
  Future<List<M3uEntry>> _parse(String source) async {
    return await _parser.parse(source);
  }
}
