import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:z_m3u_handler/src/firebase/firestore_services.dart';
import 'package:z_m3u_handler/src/models/credential_provider.dart';

class M3uFirebaseAuthService {
  M3uFirebaseAuthService._pr();
  static final M3uFirebaseAuthService _instance = M3uFirebaseAuthService._pr();
  static M3uFirebaseAuthService get instance => _instance;
  final M3uFirestoreServices _services = M3uFirestoreServices();

  // Future<User> login
  Future<CredentialProvider?> register(
      String emailAddress, String password, String url) async {
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "$emailAddress@seizhtv.com",
        password: password,
      );
      if (credential.user == null) return null;
      // fireuserId = credential.user!.uid;
      // cacher.setUID(credential.user!.uid);
      final User? user = credential.user;
      if (user == null) return null;
      await _services.addUser(credential.user!.uid, url);
      await _services.createFavoriteXHistory(credential.user!.uid);
      return CredentialProvider(user: user, url: url);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: "Password provided is too weak");
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        Fluttertoast.showToast(msg: "The email provided is already in use");
      } else {
        Fluttertoast.showToast(
            msg: "An undefined authentication error has occurred.");
      }

      return null;
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "An error has occurred while processing");
      return null;
    }
  }

  Future<CredentialProvider?> login(
      String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      final User? user = credential.user;
      if (user == null) return null;
      // fireuserId = credential.user!.uid;
      // cacher.setUID(credential.user!.uid);
      String? url = await _services.getUrl(user.uid);
      if (url == null) return null;
      return CredentialProvider(url: url, user: user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('User not found');
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        Fluttertoast.showToast(msg: "Incorrect password");
      }
      return null;
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "An error has occurred while processing");
      return null;
    }
  }

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
