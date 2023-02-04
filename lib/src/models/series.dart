import 'package:z_m3u_handler/src/models/m3u_entry.dart';

class Series {
  final String title;
  final List<M3uEntry> entries;
  const Series({
    required this.title,
    required this.entries,
  });
  factory Series.fromJson(Map<String, dynamic> json) {
    List data = json['data'] ?? [];
    return Series(
      title: json['title'] ?? "",
      entries: data.map((e) => M3uEntry.fromJson(e)).toList(),
    );
  }
}
