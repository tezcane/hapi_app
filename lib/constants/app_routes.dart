import 'package:get/get.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/ui/about_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_favorites_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_menu_ui.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';
import 'package:hapi/ui/auth/reset_password_ui.dart';
import 'package:hapi/ui/auth/sign_in_ui.dart';
import 'package:hapi/ui/auth/sign_up_ui.dart';
import 'package:hapi/ui/auth/update_profile_ui.dart';
import 'package:hapi/ui/onboarding_ui.dart';
import 'package:hapi/ui/settings_ui.dart';
import 'package:hapi/ui/splash_ui.dart';
import 'package:hapi/ui/quests_ui.dart';

class AppRoutes {
  AppRoutes._(); //this is to prevent anyone from instantiating this object
  static final routes = [
    //TODO we can customize transition to each page, just pass this to GetPages:
    //transition: Transition.leftToRightWithFade),
    GetPage(name: '/', page: () => SplashUI()),
    GetPage(name: '/onboard', page: () => OnboardingUI()),
    GetPage(name: '/signin', page: () => SignInUI()),
    GetPage(name: '/signup', page: () => SignUpUI()),
    GetPage(name: '/quest', page: () => QuestsUI()),
    GetPage(name: '/tarikh', page: () => TarikhMenuUI()),
    GetPage(name: '/tarikh/favorite', page: () => TarikhFavoritesUI()),
    GetPage(name: '/tarikh/article', page: () => TarikhArticleUI()),
    GetPage(name: '/tarikh/timeline', page: () => TarikhTimelineUI()),
    GetPage(name: '/setting', page: () => SettingsUI()),
    GetPage(name: '/setting/reset-pw', page: () => ResetPasswordUI()),
    GetPage(name: '/setting/update-profile', page: () => UpdateProfileUI()),
    GetPage(name: '/about', page: () => AboutUI()),
  ];
}
