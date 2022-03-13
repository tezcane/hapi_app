//import 'package:firebase_analytics/firebase_analytics.dart';
//import 'package:firebase_analytics/observer.dart';
import 'package:alquran_cloud/alquran_cloud.dart' as quran_cloud;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hapi/controllers/connectivity_controller.dart';
import 'package:hapi/controllers/location_controller.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/helpers/loading.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/about_ui.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/onboard/auth/sign_in_ui.dart';
import 'package:hapi/onboard/auth/sign_up_ui.dart';
import 'package:hapi/onboard/onboarding_controller.dart';
import 'package:hapi/onboard/onboarding_ui.dart';
import 'package:hapi/onboard/splash_ui.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/quest/daily/daily_quests_controller.dart';
import 'package:hapi/quest/quests_ui.dart';
import 'package:hapi/settings/language/language_controller.dart';
import 'package:hapi/settings/language/localization.g.dart';
import 'package:hapi/settings/reset_password_ui.dart';
import 'package:hapi/settings/theme/app_themes.dart';
import 'package:hapi/settings/theme/theme_controller.dart';
import 'package:hapi/settings/update_profile_ui.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_favorites_ui.dart';
import 'package:hapi/tarikh/main_menu/tarikh_menu_ui.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';
//import 'package:timezone/data/latest.dart' as tz;
//import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final GetStorage s = GetStorage(); // TODO better place/way to handle this?

/// contains info for maintaining the state of the app for the theme, language
/// and user. It initializes language and theme settings. Sets up routing.
void main() async {
  // TODO REMOVE THIS CODE LATER BUT USED TO DETECT ANDROID EMULATOR FAILING NETWORK CONNECTIONS
  /// to enable logs (disabled by default)
  quran_cloud.quranCloud.enableLogs = true;

  /// use edition identifer to determine which edition of the quran to get
  // final allEditions = await quran_cloud.getAllEditions();

  // /// also you can query the edition you want
  // final editionsQuery = await quran_cloud.getAllEditions(
  //   format: 'text', // or `audio`
  //   language:
  //       'ar', // use .getEditionSupportedLanguages(); to get the all available languages
  //   type: 'quran', // user .getEditionTypes() to get all available types
  // );

  // final quran = await quran_cloud.getQuranByEdition(allEditions.first);

  // /// get surah by number and edition
  // final surah = await quran_cloud.getSurahByEdition(1, editionsQuery.first);

  // /// get aya by number and edition
  // final aya = await quran_cloud.getAyaByNumber(2, editionsQuery.first);

  // print(aya.text); // الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ

  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();

  // TODO use other timezone options to not import as much?
  // default: doesn't contain deprecated and historical zones with some exceptions like "US/Eastern" and "Etc/UTC"; this is about 75% the size of the all database.
  // all: contains all data from the IANA time zone database.
  // 10y: default database truncated to contain historical data from 5 years ago until 5 years in the future; this database is about 25% the size of the default database.
  tz.initializeTimeZones();

  // TODO cleanup/optimize use Getx bindings?
  const bool permOn = false;
  Get.put<MainController>(MainController(),
      permanent: permOn); // should do first
  Get.put<ConnectivityController>(ConnectivityController(), permanent: permOn);
  Get.put<TimeController>(TimeController(),
      permanent: permOn); // requires ConnectivityController
  Get.put<LocationController>(LocationController(),
      permanent: permOn); // requires TimeController
  Get.put<TarikhController>(TarikhController());
  Get.put<MenuController>(MenuController(),
      permanent: permOn); //requires TarikhController
  Get.put<OnboardingController>(OnboardingController());
  Get.put<AuthController>(AuthController()); // requires OnboardingController
  Get.put<DailyQuestsController>(DailyQuestsController(),
      permanent: permOn); // requires AuthController
  Get.put<ActiveQuestsController>(ActiveQuestsController(),
      permanent: permOn); // requires AuthController
  Get.put<ActiveQuestsAjrController>(ActiveQuestsAjrController(),
      permanent: permOn); // requires ActiveQuestsController
  Get.put<ZamanController>(ZamanController(),
      permanent: permOn); // requires ActiveQuestsController
  Get.put<ThemeController>(ThemeController());
  Get.put<LanguageController>(LanguageController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeController.to.getThemeModeFromStore();

    // Must be in portrait at init, for splash, onboarding and orientation init
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return OrientationBuilder(
      builder: (context, orientation) {
        MainController.to.setOrientation(orientation == Orientation.portrait);
        return GetBuilder<LanguageController>(
          builder: (c) => Loading(
            child: MaterialApp(
              home: Scaffold(
                // floatingActionButtonLocation:
                //     FloatingActionButtonLocation.endFloat,
                resizeToAvoidBottomInset: false, // fixes keyboard pushing UI up
                floatingActionButton: GetBuilder<MenuController>(builder: (cm) {
                  return FloatingActionButton(
                    tooltip: cm.getToolTip(),
                    backgroundColor:
                        AppThemes.floatingActionButtonTheme.backgroundColor,
                    foregroundColor:
                        AppThemes.floatingActionButtonTheme.foregroundColor,
                    onPressed: () => {},
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          IconButton(
                            iconSize: 30.0,
                            icon: AnimatedIcon(
                              icon: cm.fabAnimatedIcon,
                              progress: cm.acFabIcon,
                            ),
                            onPressed: () => cm.handlePressedFAB(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                body: GetMaterialApp(
                  translations: Localization(),
                  locale: c.getLocale, // <- Current locale
                  // navigatorObservers: [
                  //   // FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
                  // ],
                  debugShowCheckedModeBanner: false,
                  // These are controlled in MenuController but we do here too for sign out/in pages
                  defaultTransition: Transition.fade,
                  transitionDuration: const Duration(milliseconds: 1000),
                  theme: AppThemes.lightTheme,
                  darkTheme: AppThemes.darkTheme,
                  themeMode: ThemeMode.dark,
                  initialRoute: "/",
                  getPages: AppRoutes.routes,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
    GetPage(name: '/about', page: () => AboutUI()),
    GetPage(name: '/about/up-prof', page: () => UpdateProfileUI()),
    GetPage(name: '/about/up-prof/reset-pw', page: () => ResetPasswordUI()),
  ];
}
