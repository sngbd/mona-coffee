import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
      await user.reload();
    }
  }

  Future<String?> getUserAvatar({required String uid}) async {
    DocumentReference<Map<String, dynamic>> user =
        FirebaseFirestore.instance.collection('users').doc(uid);
    Future<String?> avatar =
        user.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.get('avatar') as String?;
      }
      return null;
    }).catchError((error) {
      return null;
    });

    return avatar;
  }

  Future<String> updateUserAvatar(
      {required String uid, required String avatar}) async {
    CollectionReference user = FirebaseFirestore.instance.collection('users');

    return user
        .add(
          {'uid': uid, 'avatar': avatar},
        )
        .then(
          (value) => 'Successfully updated avatar',
        )
        .catchError(
          (error) => throw Exception('Failed to update avatar: $error'),
        );
  }
}
