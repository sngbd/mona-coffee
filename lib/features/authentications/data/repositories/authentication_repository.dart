import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/web.dart';
import 'package:mona_coffee/features/authentications/data/entities/user_profile.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
  void get refreshUser async => await currentUser!.reload();

  Future<UserProfile> getProfileData() async {
    if (currentUser == null) {
      throw Exception('User is not authenticated');
    }
    refreshUser;
    _firestore.clearPersistence();

    final UserProfile userProfile = UserProfile(
      name: currentUser!.displayName,
      email: currentUser!.email,
      phone: null,
      avatar: null,
    );

    final DocumentReference<Map<String, dynamic>> userRef =
        _firestore.collection('users').doc(currentUser!.uid);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await userRef.get();

    try {
      if (documentSnapshot.exists) {
        userProfile.avatar = documentSnapshot.data()?['avatar'];
        userProfile.phone = documentSnapshot.data()?['phone'];
      } else {
        Logger().e('Document does not exist');
      }
    } catch (error) {
      Logger().e('Error getting user data: $error');
    }

    return userProfile;
  }

  Future<void> updateProfileData(UserProfile userProfile) async {
    if (currentUser == null) {
      throw Exception('User is not authenticated');
    }

    if (userProfile.name != null) {
      await currentUser!.updateProfile(displayName: userProfile.name);
    }
    if (userProfile.email != null) {
      await currentUser!.verifyBeforeUpdateEmail(userProfile.email!);
    }

    final DocumentReference userRef =
        _firestore.collection('users').doc(currentUser!.uid);
    await userRef
        .set({
          'avatar': userProfile.avatar,
          'phone': userProfile.phone,
        }, SetOptions(merge: true))
        .then((value) => 'Successfully updated avatar')
        .catchError(
            (error) => throw Exception('Failed to update avatar: $error'));

    refreshUser;
  }

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
}
