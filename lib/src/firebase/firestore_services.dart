import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:z_m3u_handler/extension.dart';
import 'package:z_m3u_handler/src/models/categorized_m3u_data.dart';
import 'package:z_m3u_handler/src/models/m3u_entry.dart';

class M3uFirestoreServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// DEFAULT reference ID is user-data
  /// docRefId is the user's id
  /// it can be device's mac address or the firebase id
  Future<String?> addUser(
    String docRefId,
    String url, {
    String collectionRef = "user-data",
  }) async {
    // Call the user's CollectionReference to add a new user
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection(collectionRef);

      users.doc(docRefId).set({
        "url": url,
      });
      return url;
    } catch (e) {
      return null;
    }
  }

  /// refId is the same as userId
  /// This can be used in fav or history

  Future<bool> appendDataIn(
    M3uEntry entry, {
    required String collection,
    required String refId,
  }) async {
    try {
      if (!(await docExists(refId))) {
        print("NOT EXIST!");
        await createFavoriteXHistory(refId);
      }
      CollectionReference data =
          FirebaseFirestore.instance.collection(collection);
      await data.doc(refId).set({
        entry.type.contentStringify: FieldValue.arrayUnion([
          entry.toFireObj(),
        ])
      }, SetOptions(merge: true));
      print("ADDED SUCCESSFULLY!");
      return true;
    } catch (e) {
      print("ERROR SAVING DATA TO ${collection.toUpperCase()} : $e");
      return false;
    }
  }

  ///can only be used to fetch favorites or history

  Future<CategorizedM3UData?> getDataFrom(String refId,
      {required String collection}) async {
    try {
      if (!(await docExistsIn(refId, collection: collection))) {
        print("NOT EXIST!");
        await createDataIn(refId, collection);
        return CategorizedM3UData.empty();
      }
      CollectionReference _data =
          FirebaseFirestore.instance.collection(collection);
      // final Map<String, dynamic> ff = {};
      final DocumentSnapshot docu = await _data.doc(refId).get();
      final Map dataa = docu.data()! as Map;
      print("DATA FROM FIRESTORE : $dataa");
      if (dataa.isEmpty) {
        return CategorizedM3UData.empty();
      }
      final List<M3uEntry> _mov = ((dataa['movie'] ?? []) as List)
          .map(
            (e) => M3uEntry.fromFirestore(e, 2),
          )
          .toList();
      final List<M3uEntry> _ser = ((dataa['series'] ?? []) as List)
          .map(
            (e) => M3uEntry.fromFirestore(e, 3),
          )
          .toList();
      final List<M3uEntry> _live = ((dataa['live'] ?? []) as List)
          .map(
            (e) => M3uEntry.fromFirestore(e, 1),
          )
          .toList();
      return CategorizedM3UData(
        live: _live,
        movies: _mov.classify(),
        series: _ser.classify(),
      );
    } catch (e, s) {
      print("ERROR FETCHING : $e");
      print("STACK : $s");
      return CategorizedM3UData.empty();
    }
  }

  Future<bool> removeDataIn(
    M3uEntry entry, {
    required String collection,
    required String refId,
  }) async {
    try {
      CollectionReference data =
          FirebaseFirestore.instance.collection(collection);
      await data.doc(refId).set({
        entry.type.contentStringify: FieldValue.arrayRemove([
          entry.toFireObj(),
        ])
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> createDataIn(String refId, String collection) async {
    final Map<dynamic, dynamic> body = {"live": [], "movie": [], "series": []};
    CollectionReference data =
        FirebaseFirestore.instance.collection(collection);
    data.doc(refId).set(body);
    return "success";
  }

  Future<String?> createFavoriteXHistory(
    String refId,
  ) async {
    try {
      if (!(await docExists(refId))) {
        CollectionReference fav =
            FirebaseFirestore.instance.collection('user-favorites');
        CollectionReference history =
            FirebaseFirestore.instance.collection('user-history');
        Map body = {"live": [], "movie": [], "series": []};
        await fav.doc(refId).set(body);
        await history.doc(refId).set(body);
        return "success";
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> docExistsIn(refId, {required String collection}) async {
    try {
      CollectionReference data =
          FirebaseFirestore.instance.collection(collection);
      return await data.doc(refId).get().then((value) => value.exists);
      // CollectionReference history =
      //     FirebaseFirestore.instance.collection('user-history');
      // return await fav.doc(refId).get().then((value) => value.exists) &&
      //     await history.doc(refId).get().then((value) => value.exists);
    } catch (e) {
      return false;
    }
  }

  Future<bool> docExists(refId) async {
    try {
      CollectionReference fav =
          FirebaseFirestore.instance.collection('user-favorites');
      CollectionReference history =
          FirebaseFirestore.instance.collection('user-history');
      return await fav.doc(refId).get().then((value) => value.exists) &&
          await history.doc(refId).get().then((value) => value.exists);
    } catch (e) {
      return false;
    }
  }
}
