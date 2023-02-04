import 'package:z_m3u_handler/src/models/entry_info.dart';
export 'package:z_m3u_handler/src/models/entry_info.dart';

class M3uEntry {
  M3uEntry({
    required this.title,
    required this.attributes,
    required this.link,
    required this.duration,
  });

  factory M3uEntry.fromEntryInformation(
          {required EntryInfo information,
          required String link,
          int type = 0}) =>
      M3uEntry(
        title: information.title,
        duration: information.duration,
        attributes: information.attributes,
        link: link,
      );

  factory M3uEntry.fromJson(Map<String, dynamic> json) {
    return M3uEntry(
      title: json['title'],
      duration: json['duration'],
      attributes: json['attributes'],
      link: json['link'],
    );
  }

  String title;

  Map<String, String?> attributes;

  String link;

  int duration;

  @override
  String toString() => '${toJson()}';

  Map<String, dynamic> toJson() => {
        "title": title,
        "link": link,
        "duration": duration,
        "attributes": attributes,
      };
}
