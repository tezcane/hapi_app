//import 'package:firebase_analytics/firebase_analytics.dart';
//import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hapi/controller/connectivity_c.dart';
import 'package:hapi/controller/location_c.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/controller/notification_c.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/event/event_c.dart';
import 'package:hapi/helper/loading.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/theme_c.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/onboard/splash_ui.dart';
import 'package:hapi/quest/active/active_quests_ajr_c.dart';
import 'package:hapi/quest/active/active_quests_c.dart';
import 'package:hapi/quest/active/zaman_c.dart';
import 'package:hapi/quest/daily/daily_quests_c.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
//import 'package:timezone/data/latest.dart' as tz;
//import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// contains info for maintaining the state of the app for the theme, language
/// and user. It initializes language and theme settings. Sets up routing.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();

  // TODO use other timezone options to not import as much?
  // default: doesn't contain deprecated and historical zones with some exceptions like "US/Eastern" and "Etc/UTC"; this is about 75% the size of the all database.
  // all: contains all data from the IANA time zone database.
  // 10y: default database truncated to contain historical data from 5 years ago until 5 years in the future; this database is about 25% the size of the default database.
  tz.initializeTimeZones();

  // TODO cleanup/optimize use Getx bindings?
  const bool permOn = true;
  Get.put<MainC>(MainC(), permanent: permOn); // should do first
  Get.put<AuthC>(AuthC(), permanent: permOn); // should do second
  Get.put<ThemeC>(ThemeC());
  Get.put<LangC>(LangC(), permanent: permOn);
  Get.put<ConnectivityC>(ConnectivityC(), permanent: permOn);
  Get.put<ActiveQuestsC>(ActiveQuestsC(), permanent: permOn); // requires AuthC
  Get.put<ZamanC>(ZamanC(), permanent: permOn);
  Get.put<TimeC>(TimeC(), permanent: permOn); // requires ConnectivityC
  Get.put<NavPageC>(NavPageC(), permanent: permOn); // requires LangC, TimeC
  Get.put<MenuC>(MenuC(), permanent: permOn);
  Get.put<LocationC>(LocationC(), permanent: permOn); // requires TimeC
  Get.put<EventC>(EventC(), permanent: permOn); // requires Auth
  Get.put<RelicC>(RelicC(), permanent: permOn); // requires LangC, EventC, AuthC
  Get.put<TarikhC>(TarikhC(), permanent: permOn); // requires LangC, RelC, EvtC
  Get.put<DailyQuestsC>(DailyQuestsC(), permanent: permOn); // requires AuthC
  Get.put<NotificationC>(NotificationC(), permanent: permOn); // requires AuthC

  Get.put<ActiveQuestsAjrC>(ActiveQuestsAjrC(), permanent: permOn);

  await ThemeC.to.initTheme(); // TODO needed, best place?

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(const HapiApp());
}

class HapiApp extends StatelessWidget {
  const HapiApp();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        MainC.to.setOrientation(orientation == Orientation.portrait);
        // TODO fix arabic font size
        // MediaQueryData windowData =
        //     MediaQueryData.fromWindow(WidgetsBinding.instance.window);
        // windowData = windowData.copyWith(
        //   textScaleFactor: 1.3,
        //   // windowData.textScaleFactor > 1.4 ? 1.4 : windowData.textScaleFactor,
        // );
        return Loading(
          child: MaterialApp(
            // home: MediaQuery(
            //   data: windowData,
            home: Scaffold(
              resizeToAvoidBottomInset: false, // fixes keyboard pushing UI up
              body: GetMaterialApp(
                // useInheritedMediaQuery: true,
                // translations: Localization(),
                // locale: c.getLocale, // we set in LanguageC
                // fallbackLocale: const Locale('en', 'US'), // uses if .tr fails
                // navigatorObservers: [ // TODO
                //   // FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
                // ],
                // debugShowCheckedModeBanner: false,
                // Also set in MenuC, but we do here for sign in/out pages:
                defaultTransition: Transition.fade,
                transitionDuration: const Duration(milliseconds: 1000),
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                themeMode: ThemeMode.dark,
                initialRoute: '/',
                getPages: [GetPage(name: '/', page: () => SplashUI())],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniEndDocked,
              // MenuC to detect updates, since it has FAB logic
              floatingActionButton: GetBuilder<MenuC>(
                builder: (mc) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: MainC.to.isMainMenuFabShowing
                      ? 72 // matches bottom bar show/hide/wrap height
                      : 0, // magic that hides bottom bar
                  // Wrap needed or get overflow errors
                  child: Wrap(
                    children: [
                      // LangC to update tooltip translation
                      GetBuilder<LangC>(
                        builder: (lc) => FloatingActionButton(
                          tooltip: mc.tvMenuTooltip(),
                          backgroundColor: AppThemes
                              .floatingActionButtonTheme.backgroundColor,
                          foregroundColor: AppThemes
                              .floatingActionButtonTheme.foregroundColor,
                          // TODO fixes bug where tapping back doesn't work?:
                          onPressed: () => mc.handlePressedFAB(),
                          child: IconButton(
                            iconSize: 30.0,
                            icon: AnimatedIcon(
                              icon: mc.fabAnimatedIcon,
                              progress: mc.acFabIcon,
                            ),
                            onPressed: () => mc.handlePressedFAB(),
                          ),
                        ),
                      ),
                    ],
                    // ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// /// contains the app routes.
// class AppRoutes {
//   AppRoutes._(); //this is to prevent anyone from instantiating this object
//   static final routes = [
//     GetPage(name: '/', page: () => SplashUI()),
//     GetPage(name: '/onboard', page: () => OnboardingUI()),
//     GetPage(name: '/sign-in', page: () => SignInUI()),
//     GetPage(name: '/sign-up', page: () => SignUpUI()),
//     GetPage(name: '/quest', page: () => const QuestsUI()),
//     GetPage(name: '/tarikh', page: () => const TarikhUI()),
//     GetPage(name: '/tarikh/favorite', page: () => const TarikhFavoritesUI()),
//     GetPage(name: '/tarikh/event', page: () => TarikhArticleUI()),
//     GetPage(name: '/tarikh/timeline', page: () => TarikhTimelineUI()),
//     GetPage(name: '/about', page: () => AboutUI()),
//     GetPage(name: '/about/up-prof', page: () => UpdateProfileUI()),
//     GetPage(name: '/about/up-prof/reset-pw', page: () => ResetPasswordUI()),
//   ];
// }
