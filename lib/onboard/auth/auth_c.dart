import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/helper/gravatar.dart';
import 'package:hapi/helper/loading.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/onboard/splash_ui.dart';
import 'package:hapi/onboard/user_model.dart';

/// our user and authentication functions for creating, logging in and out our
/// user and saving our user data.
class AuthC extends GetxHapi {
  static AuthC get to => Get.find();

  Stopwatch splashTimer = Stopwatch();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<UserModel> fsUser = Rxn<UserModel>(); // fs= firestore
  bool admin = false;

  /// SplashUI has gif timer is used to swap gif to png for hero animation
  bool _isGifAnimatingDone = false;
  bool isGifAnimatingDone() => _isGifAnimatingDone;
  void setGifAnimatingDone() {
    _isGifAnimatingDone = true;
    update();
  }

  bool _isSplashScreenDone = false;
  bool isSplashScreenDone() => _isSplashScreenDone;
  void setSplashScreenToDone() {
    _isSplashScreenDone = true;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    splashTimer.start();
  }

  @override
  void onReady() async {
    //run every time auth state changes
    ever(firebaseUser, handleAuthChanged);

    firebaseUser.bindStream(user);

    super.onReady();
  }

  String getEmail() {
    emailController.text = s.rd('lastSignedInEmail') ?? '';
    return emailController.text;
  }

  /// This is used when user is onboarding (not signed in), so it is not stored
  /// only on cleaned data like "storeLastSignedInName".
  storeEmail() => s.wr('lastSignedInEmail', emailController.text.trim());

  String getLastSignedInName() {
    nameController.text = s.rd('lastSignedInName') ?? '';
    return nameController.text;
  }

  storeLastSignedInName() =>
      s.wr('lastSignedInName', nameController.text.trim());

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /* TODO deleted user can still use app:
      [GETX] Instance "QuestC" has been created
      I/flutter ( 4937): Going to /quest
      I/flutter ( 4937): QuestC.onInit: binding to db with uid=CjuUHwo5iIPWYa878zpsJzGCKev1
      [GETX] Instance "QuestC" has been initialized
      W/Firestore( 4937): (22.0.1) [Firestore]: Listen for Query(target=Query(user/CjuUHwo5iIPWYa878zpsJzGCKev1 order by __name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
      E/flutter ( 4937): [ERROR:flutter/lib/onboard/ui_dart_state.cc(186)] Unhandled Exception: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
      E/flutter ( 4937):
      E/flutter ( 4937): [ERROR:flutter/lib/onboard/ui_dart_state.cc(186)] Unhandled Exception: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
      E/flutter ( 4937):
      W/Firestore( 4937): (22.0.1) [Firestore]: Listen for Query(target=Query(user/CjuUHwo5iIPWYa878zpsJzGCKev1/quest order by -dateCreated, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
      E/flutter ( 4937): [ERROR:flutter/lib/onboard/ui_dart_state.cc(186)] Unhandled Exception: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
   */
  handleAuthChanged(_firebaseUser) async {
    //get user data from firestore
    if (_firebaseUser?.uid != null) {
      s.setUidKey(_firebaseUser!.uid);
      fsUser.bindStream(_streamFirestoreUser()); // TODO bindstream?
      await awaitUser(); // used to be named await isAdmin();
    }

    /// TODO need to detect if user is deleted/banned/not found, etc. here.
    if (_firebaseUser == null) {
      // TODO asdf check onboarding logic, was jsut:
      // if (OnboardingC.to.isOnboarded) {
      //   Get.offAll(() => SignInUI());
      // } else {
      //   Get.offAll(() => OnboardingUI());
      // }
      MainC.to.signOut();
    } else {
      splashTimer.stop();
      int msLeftToShowSplash =
          kSplashShowTimeMs - splashTimer.elapsedMilliseconds;
      if (MenuC.to.isFastStartupMode() || msLeftToShowSplash < 0) {
        msLeftToShowSplash = 0;
      }

      Timer(Duration(milliseconds: msLeftToShowSplash), () {
        setSplashScreenToDone(); // turns off Splash spinner so not in hero fade
        MainC.to.signIn();
      });
    }
  }

  /// Firebase user one-time fetch
  Future<User> get getUser async => _auth.currentUser!;

  /// Firebase user a realtime stream
  Stream<User?> get user => _auth.authStateChanges();

  /// Streams the firestore user from the firestore collection
  Stream<UserModel> _streamFirestoreUser() {
    l.v('streamFirestoreUser()');

    return _db
        .doc('/user/${firebaseUser.value!.uid}')
        .snapshots()
        .map((snapshot) {
      UserModel userModel = UserModel.fromJson(snapshot.data()!);

      // Loaded user from db, we must update name and email settings as the
      // user may have signed in, so the app has not history of name. Good to
      // update email too in case it is ever changed server side.
      nameController.text = userModel.name;
      storeLastSignedInName();

      emailController.text = userModel.email;
      storeEmail();

      return userModel;
    });
  }

  // /// get the firestore user from the firestore collection
  // Future<UserModel> _getFirestoreUser() {
  //   return _db.doc('/user/${firebaseUser.value!.uid}').get().then(
  //       (documentSnapshot) => UserModel.fromJson(documentSnapshot.data()!));
  // }

  /// Method to handle user sign in using email and password
  signInWithEmailAndPassword(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      storeLastSignedInName();
      storeEmail();

      passwordController.clear();
      hideLoadingIndicator();
      MainC.to.signIn();
    } catch (error) {
      hideLoadingIndicator();
      showSnackBar(
        'Error Signing In',
        'Email or password is incorrect',
        durationSec: 7,
        isRed: true,
      );
    }
  }

  /// User registration using email and password
  registerWithEmailAndPassword(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text)
          .then((result) async {
        l.d('uID: ' + result.user!.uid.toString());
        l.d('email: ' + result.user!.email.toString());
        //get photo url from gravatar if user has one
        Gravatar gravatar = Gravatar(emailController.text.trim());
        String gravatarUrl = gravatar.imageUrl(
          // TODO tune this, make cooler
          size: 200,
          defaultImage: GravatarImage.retro,
          rating: GravatarRating.pg,
          fileExtension: true,
        );
        //create the new user object
        UserModel _newUser = UserModel(
          uid: result.user!.uid,
          email: result.user!.email!,
          name: nameController.text,
          photoUrl: gravatarUrl,
        );

        // create the user in firestore
        _createUserFirestore(_newUser, result.user!);

        storeLastSignedInName();
        storeEmail();

        // emailController.clear();
        passwordController.clear();

        hideLoadingIndicator();
        MainC.to.signIn();
      });
    } on FirebaseAuthException catch (error) {
      hideLoadingIndicator();
      showSnackBar(
        'Sign Up Failed',
        error.message!,
        durationSec: 10,
        isRed: true,
      );
    }
  }

  /// handles updating the user when updating profile
  /// Note, this is highly modified by Tez, error reported here but tez fixed it:
  ///   "not yet working, see this issue https://github.com/delay/flutter_starter/issues/21"
  Future<bool> updateUser(BuildContext context, UserModel user, String oldEmail,
      String password) async {
    try {
      showLoadingIndicator();

      await _auth
          .signInWithEmailAndPassword(email: oldEmail, password: password)
          .then((_firebaseUser) async =>
              await _firebaseUser.user!.updateEmail(user.email).then(
                    (value) async =>
                        await _updateUserFirestore(user, _firebaseUser.user!),
                  ));

      hideLoadingIndicator();

      storeLastSignedInName();
      storeEmail();

      showSnackBar(
        'User Updated',
        'User information successfully updated.',
      );
      return Future.value(false);
    } catch (error) /* "}on PlatformException catch (error){" misses errors */ {
      hideLoadingIndicator();

      // Don't do this so UI Update Profile button stays enabled with last
      // entered bad input:
      // // update failed so restore good name/email back to UI
      // getLastSignedInName();
      // getLastSignedInEmail();

      showSnackBar(
        'Failed to update user',
        tkForFirestoreAuthFailure(error.toString()),
        durationSec: 10,
        isRed: true,
      );
    }
    return Future.value(true);
  }

  /// Convert auth error to translated nice user output.
  String tkForFirestoreAuthFailure(String authError) {
    // Note: leaves brackets around unknown errors. i.e. "[unknown-err] err msg"
    authError = authError.replaceFirst('firebase_auth/', '');

    String error = authError.toLowerCase(); // to match below
    if (error.contains('invalid-email')) {
      return 'Must be a valid email address';
    } else if (error.contains('email-already-in-use')) {
      return 'This email address already has an account. Sign in?';
    } else if (error.contains('wrong-password')) {
      return 'The password does not match our records.';
    } else if (error.contains('weak-password')) {
      return 'Password must be at least 6 characters';
    } else if (error.contains('user-disabled')) {
      return 'This account was disabled by the admin.';
    }

    // I don't expect to see these
    l.e('Strange/unexpected error: $authError');
    if (error.contains('user-not-found')) {
      return 'Email or password is incorrect';
    } else if (error.contains('too-many-requests')) {
      return 'Too many requests were made.';
    } else if (error.contains('operation-not-allowed')) {
      return 'This operation is not allowed.';
    } else if (error.contains('requires-recent-login')) {
      return 'This operation requires a recent login.';
    } else {
      return 'Unknown Error'.tr +
          ': ' +
          authError; // tr ok, unknown translation, shows en
    }
  }

  /// updates the firestore user in users collection
  _updateUserFirestore(UserModel user, User _firebaseUser) async {
    await _db.doc('/user/${_firebaseUser.uid}').update(user.toJson());
    update();
  }

  /// create the firestore user in users collection
  void _createUserFirestore(UserModel user, User _firebaseUser) {
    s.wr('lastSignedInEmail', user.email);
    _db.doc('/user/${_firebaseUser.uid}').set(user.toJson());
    update();
  }

  /// password reset email
  Future<void> sendPasswordResetEmail(String newEmail) async {
    showLoadingIndicator();
    try {
      await _auth.sendPasswordResetEmail(email: newEmail);
      hideLoadingIndicator();
      showSnackBar(
        'Password Reset Email Sent',
        'To reset your password, follow the emailed instructions.',
        durationSec: 10,
      );
    } on FirebaseAuthException catch (error) {
      hideLoadingIndicator();
      showSnackBar(
        'Failed to send password reset email.',
        error.message!,
        durationSec: 10,
        isRed: true,
      );
    }
  }

  awaitUser() async {
    await getUser.then((User user) async {
      /// check if user is an admin user
      /* TODO needed? This fails when the app goes offline:
      DocumentSnapshot adminRef =
          await _db.collection('admin').doc(user.uid).get();
      if (adminRef.exists) {
        admin = true;
      } else { */
      admin = false;
/*    } */
      update();
    });
  }

  /// Sign out
  Future<void> signOut() {
    getEmail(); // show it in case user forgets what email they used

    s.setUidKey('noLogin'); // clear for next user

    storeEmail(); // store with 'noLogin' so persists

    nameController.clear();
    // emailController.clear();
    getEmail(); // show it in case user forgets what email they used
    passwordController.clear();
    return _auth.signOut();
  }

  /// Prevent exceptions when pages called without auth init done.
  waitForFirebaseLogin(String caller) async {
    int sleepBackoffMs = 250;
    // No internet needed if already initialized
    while (firebaseUser.value == null) {
      l.d('AuthController.waitForFirebaseLogin($caller): try again after sleeping $sleepBackoffMs ms...');
      //sleep(Duration(milliseconds: sleepBackoffMs));
      await Future.delayed(Duration(milliseconds: sleepBackoffMs));
      if (sleepBackoffMs < 1000) sleepBackoffMs += 250;
    }
  }
}
