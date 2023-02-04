import 'package:z_m3u_handler/src/models/m3u_entry.dart';

extension SORTER on List<M3uEntry> {
  Map<String, List<M3uEntry>> categorize({required String needle}) {
    return fold(<String, List<M3uEntry>>{}, (acc, current) {
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
