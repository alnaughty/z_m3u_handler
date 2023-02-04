import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:z_m3u_handler/extension.dart';
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
  Future<bool> updateEntry(List<M3uEntry> data,
      {required String collection, required String refId}) async {
    try {
      final CollectionReference _data =
          FirebaseFirestore.instance.collection(collection);
      final DocumentSnapshot docu = await _data.doc(refId).get();
      await _data.doc(refId).set({
        "movie": docu.get("movie"),
        "live": docu.get("live"),
        "series": data.map((e) => e.toJson()).toList(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> appendDataIn(
    M3uEntry entry, {
    required String collection,
    required String refId,
  }) async {
    try {
      CollectionReference data =
          FirebaseFirestore.instance.collection(collection);
      // final DocumentSnapshot docu = await data.doc(refId).get();
      // List ff = await docu.get("data");
      // ff.add(entry.toJson());
      // data.doc(refId).update(data)
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
