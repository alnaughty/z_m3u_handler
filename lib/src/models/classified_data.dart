import 'package:z_m3u_handler/z_m3u_handler.dart';

class ClassifiedData {
  final String name;
  final List<M3uEntry> data;
  const ClassifiedData({required this.name, required this.data});

  Map<String, dynamic> toMap() => {
        "name": name,
        "data": data.map((e) => e.toString()).toList(),
      };
  @override
  String toString() => "${toMap()}";
}
