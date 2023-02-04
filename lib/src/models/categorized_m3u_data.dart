import 'package:z_m3u_handler/src/models/m3u_entry.dart';

class CategorizedM3UData {
  final List<M3uEntry> series;
  final List<M3uEntry> movies;
  final List<M3uEntry> live;

  const CategorizedM3UData(
      {required this.live, required this.movies, required this.series});
  factory CategorizedM3UData.empty() =>
      const CategorizedM3UData(live: [], movies: [], series: []);
  @override
  String toString() => "${toJson()}";
  Map<String, dynamic> toJson() => {
        "series": series,
        "movies": movies,
        "live": live,
      };
}
