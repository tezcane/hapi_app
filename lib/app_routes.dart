import 'package:get/get.dart';
import 'package:hapi/menu/about_ui.dart';
import 'package:hapi/onboard/auth/sign_in_ui.dart';
import 'package:hapi/onboard/auth/sign_up_ui.dart';
import 'package:hapi/onboard/onboarding_ui.dart';
import 'package:hapi/onboard/splash_ui.dart';
import 'package:hapi/quest/quests_ui.dart';
import 'package:hapi/settings/reset_password_ui.dart';
import 'package:hapi/settings/settings_ui.dart';
import 'package:hapi/settings/update_profile_ui.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_favorites_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_menu_ui.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';

/// contains the app routes.
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
