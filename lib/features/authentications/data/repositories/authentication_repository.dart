import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _google = GoogleSignIn();

  AuthenticationRepository(this._firebaseAuth);

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _google.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOutGoogle() async {
    await _google.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> updateProfile({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      if (displayName != null || photoUrl != null) {
        await user.updateProfile(displayName: displayName, photoURL: photoUrl);
      }
      if (email != null) {
        await user.verifyBeforeUpdateEmail(email);
      }
      // Note: Updating phone number requires re-authentication and a verification process.
      // await user.updatePhoneNumber(...);
      await user.reload();
    }
  }
}
