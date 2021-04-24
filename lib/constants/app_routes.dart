import 'package:get/get.dart';
import 'package:hapi/ui/auth/reset_password_ui.dart';
import 'package:hapi/ui/auth/sign_in_ui.dart';
import 'package:hapi/ui/auth/sign_up_ui.dart';
import 'package:hapi/ui/auth/update_profile_ui.dart';
import 'package:hapi/ui/home_ui.dart';
import 'package:hapi/ui/onboarding_ui.dart';
import 'package:hapi/ui/settings_ui.dart';
import 'package:hapi/ui/splash_ui.dart';
import 'package:hapi/ui/tasks_ui.dart';

class AppRoutes {
  AppRoutes._(); //this is to prevent anyone from instantiating this object
  static final routes = [
    GetPage(name: '/', page: () => SplashUI()),
    GetPage(name: '/onboarding', page: () => OnboardingUI()),
    GetPage(name: '/signin', page: () => SignInUI()),
    GetPage(name: '/signup', page: () => SignUpUI()),
    GetPage(name: '/home', page: () => HomeUI()),
    GetPage(name: '/tasks', page: () => TasksUI()),
    GetPage(name: '/settings', page: () => SettingsUI()),
    GetPage(name: '/reset-password', page: () => ResetPasswordUI()),
    GetPage(name: '/update-profile', page: () => UpdateProfileUI()),
  ];
}
