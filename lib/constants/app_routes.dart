import 'package:get/get.dart';
import 'package:hapi/ui/auth/reset_password_ui.dart';
import 'package:hapi/ui/auth/sign_in_ui.dart';
import 'package:hapi/ui/auth/sign_up_ui.dart';
import 'package:hapi/ui/auth/update_profile_ui.dart';
import 'package:hapi/ui/home_ui.dart';
import 'package:hapi/ui/onboarding_ui.dart';
import 'package:hapi/ui/settings_ui.dart';
import 'package:hapi/ui/splash_ui.dart';
import 'package:hapi/ui/quests_ui.dart';

class AppRoutes {
  AppRoutes._(); //this is to prevent anyone from instantiating this object
  static final routes = [
    GetPage(name: '/', page: () => SplashUI()),
    GetPage(name: '/onboard', page: () => OnboardingUI()),
    GetPage(name: '/signin', page: () => SignInUI()),
    GetPage(name: '/signup', page: () => SignUpUI()),
    GetPage(name: '/home', page: () => HomeUI()),
    GetPage(name: '/quest', page: () => QuestsUI()),
    GetPage(name: '/setting', page: () => SettingsUI()),
    GetPage(name: '/reset-pw', page: () => ResetPasswordUI()),
    GetPage(name: '/update-profile', page: () => UpdateProfileUI()),
  ];
}
