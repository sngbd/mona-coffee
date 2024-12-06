import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/web.dart';
import 'package:mona_coffee/features/authentications/data/entities/user_profile.dart';
import 'package:http/http.dart' as http;

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
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateFcmToken(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
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

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      await _updateFcmToken(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    final isGoogle = await isUserLoggedInWithGoogle();
    if (isGoogle) {
      await _google.signOut();
    }
    await _firebaseAuth.signOut();
    await _refreshFcmToken();
  }

  User? get currentUser => _firebaseAuth.currentUser;
  void get refreshUser async => await currentUser!.reload();

  Future<bool> isUserLoggedInWithGoogle() async {
    final user = currentUser;
    if (user != null) {
      for (var userInfo in user.providerData) {
        if (userInfo.providerId == 'google.com') {
          return true;
        }
      }
    }
    return false;
  }

  Future<UserProfile> getProfileData() async {
    if (currentUser == null) {
      throw Exception('User is not authenticated');
    }
    refreshUser;

    final bool isGoogle = await isUserLoggedInWithGoogle();
    if (isGoogle) {
      final response = await http.get(Uri.parse(
          currentUser!.photoURL ?? 'https://via.placeholder.com/150'));
      String avatar;

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        avatar = base64Encode(bytes);
      } else {
        throw Exception('Failed to download file');
      }

      final UserProfile userProfile = UserProfile(
        name: currentUser!.displayName,
        email: currentUser!.email,
        phone: null,
        avatar: avatar,
      );

      return userProfile;
    }

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

  Future<void> sendResetPassword(String email) async {
    Logger().i('Sending password reset email to $email');
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> _updateFcmToken(User? user) async {
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    final DocumentReference userRef =
        _firestore.collection('users').doc(user.uid);
    await userRef.set({
      'fcmToken': fcmToken,
    }, SetOptions(merge: true));
  }

  Future<void> _refreshFcmToken() async {
    await FirebaseMessaging.instance.deleteToken();
    String? newFcmToken = await FirebaseMessaging.instance.getToken();
    if (newFcmToken != null) {
      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        final DocumentReference userRef =
            _firestore.collection('users').doc(user.uid);
        await userRef.set({
          'fcmToken': newFcmToken,
        }, SetOptions(merge: true));
      }
    }
  }
}
