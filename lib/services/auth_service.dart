import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // যদি ফেসবুক পুরোপুরি বাদ দাও, তবে এটি মুছে দিও

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ১. GoogleSignIn এখন সিঙ্গলটন, তাই .instance ব্যবহার করতে হবে
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  // ২. নতুন ভার্সনে যেকোনো কাজের আগে গুগল সাইন-ইন initialize করতে হয়
  Future<void> _ensureGoogleInitialized() async {
    if (!_isGoogleInitialized) {
      await _googleSignIn.initialize();
      _isGoogleInitialized = true;
    }
  }

  // --- Email/Password Login ---
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      print("Email Sign-in Error: ${e.message}");
      throw e;
    }
  }

  // --- Email/Password Registration ---
  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      print("Email Registration Error: ${e.message}");
      throw e;
    }
  }

  // --- Google Login (Updated for v7.0.0+) ---
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // আগে initialize করতে হবে
      await _ensureGoogleInitialized();

      // ৩. signIn() এর বদলে authenticate() ব্যবহার করতে হবে
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) return null; // ইউজার ক্যানসেল করলে

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // ৪. নতুন ভার্সনে accessToken বাদ দেওয়া হয়েছে। ফায়ারবেসের জন্য শুধু idToken-ই যথেষ্ট!
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign In Error: $e");
      throw Exception("Google login failed");
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); // এখানেও .instance এর ভ্যারিয়েবল ইউজ করা হলো
      // await FacebookAuth.instance.logOut(); // ফেসবুক রাখলে আনকমেন্ট করবে
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }
}