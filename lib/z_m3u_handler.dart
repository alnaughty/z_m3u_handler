library z_m3u_handler;

import 'dart:io';

import 'package:flutter/material.dart';
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
      final String? data = await getSource(await _file.readAsString());
      if (data == null) return [];
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
    final String? data = await getSource(await _file.readAsString());
    if (data == null) return [];
    return await _parse(data);
  }

  Future<String?> getSource(String path) async {
    if (path.isEmpty) return null;
    if (File(path).existsSync()) return null;
    final File _file = await File(path).create(recursive: true);
    if (_file.existsSync()) {
      return _file.readAsStringSync();
    }
  }

  // ZM3UHandler.network(String url, ValueChanged)
  //     : _data = _processNetwork(url),
  //       assert(url.isNotEmpty, "Url should not be empty");
  // ZM3UHandler.path(String path)
  //     : _data = _processFile(path),
  //       assert(path.isNotEmpty),
  //       assert(path.contains(".m3u"), "File must end with .m3u");
  // final List<M3uEntry> _data;
  static final FileDownloader _downloader = FileDownloader();
  // List<M3uEntry> get data => _data;
  static final M3uParser _parser = M3uParser.instance;

  Future<List<M3uEntry>> _parse(String source) async {
    return await _parser.parse(source);
  }
}
