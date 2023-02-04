import 'package:z_m3u_handler/src/models/m3u_entry.dart';

mixin Categorizer {
  Map<String, List<M3uEntry>> categorizeFile(
      {required List<M3uEntry> data, required String needle}) {
    return data.fold(<String, List<M3uEntry>>{}, (acc, current) {
      final property = current.attributes[needle] ?? "tvg-id";

      if (!acc.containsKey(property)) {
        acc[property] = [current];
      } else {
        acc[property]!.add(current);
      }
      return acc;
    });
  }
}
