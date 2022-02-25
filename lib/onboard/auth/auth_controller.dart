import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/helpers/gravatar.dart';
import 'package:hapi/helpers/loading.dart';
import 'package:hapi/main.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/onboard/auth/sign_in_ui.dart';
import 'package:hapi/onboard/onboarding_controller.dart';
import 'package:hapi/onboard/onboarding_ui.dart';
import 'package:hapi/onboard/splash_ui.dart';
import 'package:hapi/onboard/user_model.dart';

/// our user and authentication functions for creating, logging in and out our
/// user and saving our user data.
class AuthController extends GetxHapi {
  static AuthController to = Get.find();
  final OnboardingController onboardingController = OnboardingController.to;

  Stopwatch splashTimer = Stopwatch();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<UserModel> firestoreUser = Rxn<UserModel>();
  final RxBool admin = false.obs;

  /// SplashUI has gif timer is used to swap gif to png for hero animation
  final RxBool _isGifAnimatingDone = false.obs;
  bool isGifAnimatingDone() => _isGifAnimatingDone.value;
  void setGifAnimatingDone() {
    _isGifAnimatingDone.value = true;
    update();
  }

  final RxBool _isSplashScreenDone = false.obs;
  bool isSplashScreenDone() => _isSplashScreenDone.value;
  void setSplashScreenToDone() {
    _isSplashScreenDone.value = true;
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

    getLastSignedInName();
    getLastSignedInEmail();

    super.onReady();
  }

  String getLastSignedInEmail() {
    emailController.text = s.read('lastSignedInEmail') ?? '';
    return emailController.text;
  }

  storeLastSignedInEmail() =>
      s.write('lastSignedInEmail', emailController.text.trim());

  String getLastSignedInName() {
    nameController.text = s.read('lastSignedInName') ?? '';
    return nameController.text;
  }

  storeLastSignedInName() =>
      s.write('lastSignedInName', nameController.text.trim());

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /* TODO deleted user can still use app:
      [GETX] Instance "QuestController" has been created
      I/flutter ( 4937): Going to /quest
      I/flutter ( 4937): QuestController.onInit: binding to db with uid=CjuUHwo5iIPWYa878zpsJzGCKev1
      [GETX] Instance "QuestController" has been initialized
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
      firestoreUser.bindStream(streamFirestoreUser());
      await isAdmin();
    }

    if (_firebaseUser == null) {
      if (onboardingController.isOnboarded()) {
        Get.offAll(() => SignInUI());
      } else {
        Get.offAll(() => OnboardingUI());
      }
    } else {
      splashTimer.stop();
      int msLeftToShowSplash =
          kSplashShowTimeMs - splashTimer.elapsedMilliseconds;
      if (cMenu.isFastStartupMode() || msLeftToShowSplash < 0) {
        msLeftToShowSplash = 0;
      }

      Timer(Duration(milliseconds: msLeftToShowSplash), () {
        setSplashScreenToDone(); // turns off Splash spinner so not in hero fade
        cMenu.initAppsFirstPage();
      });
    }
  }

  /// Firebase user one-time fetch
  Future<User> get getUser async => _auth.currentUser!;

  /// Firebase user a realtime stream
  Stream<User?> get user => _auth.authStateChanges();

  /// Streams the firestore user from the firestore collection
  Stream<UserModel> streamFirestoreUser() {
    print('streamFirestoreUser()');

    return _db
        .doc('/user/${firebaseUser.value!.uid}')
        .snapshots()
        .map((snapshot) => UserModel.fromJson(snapshot.data()!));
  }

  /// get the firestore user from the firestore collection
  Future<UserModel> getFirestoreUser() {
    return _db.doc('/user/${firebaseUser.value!.uid}').get().then(
        (documentSnapshot) => UserModel.fromJson(documentSnapshot.data()!));
  }

  /// Method to handle user sign in using email and password
  signInWithEmailAndPassword(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      storeLastSignedInName(); // tez
      storeLastSignedInEmail();
      //emailController.clear();
      passwordController.clear();
      hideLoadingIndicator();
    } catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.signInErrorTitle'.tr, 'auth.signInError'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 7),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
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
        print('uID: ' + result.user!.uid.toString());
        print('email: ' + result.user!.email.toString());
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
            photoUrl: gravatarUrl);
        //create the user in firestore
        _createUserFirestore(_newUser, result.user!);
        storeLastSignedInName(); // tez
        storeLastSignedInEmail();
        //emailController.clear();
        passwordController.clear();
        hideLoadingIndicator();
      });
    } on FirebaseAuthException catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.signUpErrorTitle'.tr, error.message!,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  /// handles updating the user when updating profile
  /// Note, this is highly modified by Tez, error reported here but tez fixed it:
  ///   "not yet working, see this issue https://github.com/delay/flutter_starter/issues/21"
  Future<void> updateUser(BuildContext context, UserModel user, String oldEmail,
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
      storeLastSignedInEmail();

      Get.snackbar('auth.updateUserSuccessNoticeTitle'.tr,
          'auth.updateUserSuccessNotice'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    } catch (error) {
      // "} on  PlatformException catch (error) {" doesn't catch all error types

      hideLoadingIndicator();

      // update failed so restore good name/email back to UI
      getLastSignedInName();
      getLastSignedInEmail();

      Get.snackbar('auth.updateUserFailNotice'.tr,
          translateFirestoreAuthFailure(error.toString()),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  /// Convert auth error to translated nice user output.
  String translateFirestoreAuthFailure(String authError) {
    // Note: leaves brackets around unknown errors. i.e. "[unknown-err] err msg"
    authError = authError.replaceFirst("firebase_auth/", "");

    String error = authError.toLowerCase(); // to match below
    if (error.contains("invalid-email")) {
      return 'validator.email'.tr;
    } else if (error.contains("email-already-in-use")) {
      return 'auth.updateUserEmailInUse'.tr;
    } else if (error.contains("wrong-password")) {
      return 'auth.wrongPasswordNotice'.tr;
    } else if (error.contains("weak-password")) {
      return 'validator.password'.tr;
    } else if (error.contains("user-disabled")) {
      return 'auth.userIsAdminDisabled'.tr;
    }

    // I don't expect to see these
    print('Strange/unexpected error: $authError');
    if (error.contains("user-not-found")) {
      return 'auth.signInError'.tr;
    } else if (error.contains("too-many-requests")) {
      return 'auth.tooManyRequests'.tr;
    } else if (error.contains("operation-not-allowed")) {
      return 'auth.operationNotAllowed'.tr;
    } else if (error.contains("requires-recent-login")) {
      return 'auth.requiresRecentLogin'.tr;
    } else {
      return 'auth.unknownError'.tr + ": " + authError;
    }
  }

  /// updates the firestore user in users collection
  _updateUserFirestore(UserModel user, User _firebaseUser) async {
    await _db.doc('/user/${_firebaseUser.uid}').update(user.toJson());
    update();
  }

  /// create the firestore user in users collection
  void _createUserFirestore(UserModel user, User _firebaseUser) {
    s.write('lastSignedInEmail', user.email);
    _db.doc('/user/${_firebaseUser.uid}').set(user.toJson());
    update();
  }

  /// password reset email
  Future<void> sendPasswordResetEmail(BuildContext context) async {
    showLoadingIndicator();
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text);
      hideLoadingIndicator();
      Get.snackbar(
          'auth.resetPasswordNoticeTitle'.tr, 'auth.resetPasswordNotice'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    } on FirebaseAuthException catch (error) {
      hideLoadingIndicator();
      Get.snackbar('auth.resetPasswordFailed'.tr, error.message!,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          backgroundColor: Get.theme.snackBarTheme.backgroundColor,
          colorText: Get.theme.snackBarTheme.actionTextColor);
    }
  }

  /// check if user is an admin user
  isAdmin() async {
    await getUser.then((user) async {
      // TODO needed? This fails when the app goes offline:
      // DocumentSnapshot adminRef =
      //     await _db.collection('admin').doc(user.uid).get();
      // if (adminRef.exists) {
      //   admin.value = true;
      // } else {
      admin.value = false;
      // }
      update();
    });
  }

  /// Sign out
  Future<void> signOut() {
    nameController.clear();
    //emailController.clear();
    getLastSignedInEmail(); // show it in case user forgets what email they used
    passwordController.clear();
    return _auth.signOut();
  }
}
