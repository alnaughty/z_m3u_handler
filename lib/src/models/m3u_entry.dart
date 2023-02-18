import 'package:z_m3u_handler/src/firebase/firestore_services.dart';
import 'package:z_m3u_handler/src/models/entry_info.dart';
export 'package:z_m3u_handler/src/models/entry_info.dart';

class M3uEntry {
  static final M3uFirestoreServices _fserve = M3uFirestoreServices();
  M3uEntry({
    required this.title,
    required this.attributes,
    required this.link,
    required this.duration,
    required this.type,
  });

  ///refId is representation of userId
  Future<void> addToFavorites(String refId) async {
    await _fserve.appendDataIn(
      this,
      collection: "user-favorites",
      refId: refId,
    );
  }

  Future<void> removeFromFavorites(String refId) async {
    await _fserve.removeDataIn(
      this,
      collection: "user-favorites",
      refId: refId,
    );
  }

  Future<void> addToHistory(String refId) async {
    await _fserve.appendDataIn(
      this,
      collection: "user-history",
      refId: refId,
    );
  }

  Future<void> removeFromHistory(String refId) async {
    await _fserve.removeDataIn(
      this,
      collection: "user-history",
      refId: refId,
    );
  }

  factory M3uEntry.fromFirestore(Map<String, dynamic> json, int type) {
    return M3uEntry(
      title: json['name'],
      attributes: {
        "tvg-logo": json['image'],
      },
      link: json['url'],
      duration: json['duration'].toInt(),
      type: type,
    );
  }
  factory M3uEntry.fromEntryInformation(
          {required EntryInfo information,
          required String link,
          int type = 0}) =>
      M3uEntry(
        title: information.title,
        duration: information.duration,
        attributes: information.attributes,
        link: link,
        type: type,
      );

  // factory M3uEntry.fromJson(Map<String, dynamic> json) {
  //   final String link = json['link'];
  //   return M3uEntry(
  //     title: json['title'],
  //     duration: json['duration'],
  //     attributes: json['attributes'],
  //     link: json['link'],
  //     type: link.getType,
  //   );
  // }

  String title;

  Map<String, String?> attributes;

  String link;

  int duration;
  int type;

  @override
  String toString() => '${toJson()}';

  Map<String, dynamic> toJson() => {
        "title": title,
        "link": link,
        "duration": duration,
        "type": type,
        "attributes": attributes,
      };

  Map<String, dynamic> toDBObj() => {
        "title": title,
        "link": link,
        "duration": duration,
        "image": attributes['tvg-logo'] ?? "",
        "type": type,
      };
  Map<String, dynamic> toFireObj() => {
        "name": title,
        "url": link,
        "duration": duration,
        "image": attributes['tvg-logo'] ?? "",
      };
}
