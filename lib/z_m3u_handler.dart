library z_m3u_handler;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:z_m3u_handler/src/databaase/db_handler.dart';
import 'package:z_m3u_handler/src/helpers/file_downloader.dart';
import 'package:z_m3u_handler/src/helpers/parser.dart';
import 'package:z_m3u_handler/src/models/m3u_entry.dart';

class ZM3UHandler {
  ZM3UHandler._pr();
  static final ZM3UHandler _instance = ZM3UHandler._pr();
  static ZM3UHandler get instance => _instance;
  Future<List<M3uEntry>> network(
      String url, ValueChanged<double> progressCallback) async {
    print("ASDADAS");
    try {
      final File? _file = await _downloader.downloadFile(
        url,
        progressCallback,
      );
      if (_file == null) return [];
      final String data = await _file.readAsString();

      return await _parse(data);
    } catch (e, s) {
      print("ERR : $e");
      print("STCK : $s");
      return [];
    }
  }

  Future<List<M3uEntry>> file(
      String path, ValueChanged<double> progressCallback) async {
    print("ASDADAS");
    final File _file = File(path);

    if (!_file.existsSync()) {
      _file.createSync();
    }
    final String data = await _file.readAsString();

    return await _parse(data);
  }

  Future<void> _saveTODB(List<M3uEntry> data) async {
    try {
      await _dbHandler.clearTable();
      // await _dbHandler.addEntry(categoryID, entry);
    } catch (e) {
      return;
    }
  }

  static final FileDownloader _downloader = FileDownloader();

  static final M3uParser _parser = M3uParser.instance;
  static final DBHandler _dbHandler = DBHandler.instance;
  Future<List<M3uEntry>> _parse(String source) async {
    return await _parser.parse(source);
  }
}
