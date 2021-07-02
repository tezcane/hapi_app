//import 'package:firebase_analytics/firebase_analytics.dart';
//import 'package:firebase_analytics/observer.dart';
import 'package:alquran_cloud/alquran_cloud.dart' as quran_cloud;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hapi/constants/app_routes.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/controllers/language_controller.dart';
import 'package:hapi/controllers/onboarding_controller.dart';
import 'package:hapi/controllers/theme_controller.dart';
import 'package:hapi/helpers/localization.g.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/ui/components/loading.dart';

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
  await Firebase.initializeApp();
  await GetStorage.init();

  // TODO cleanup/optimize use Getx bindings?
  Get.put<MainController>(MainController());
  Get.put<OnboardingController>(OnboardingController());
  Get.put<AuthController>(AuthController());
  Get.put<MenuController>(MenuController());
  Get.put<ActiveQuestsAjrController>(ActiveQuestsAjrController());
  Get.put<ZamanController>(ZamanController());
  Get.put<ActiveQuestsController>(ActiveQuestsController());
  Get.put<TarikhController>(TarikhController());
  Get.put<ThemeController>(ThemeController());
  Get.put<LanguageController>(LanguageController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeController.to.getThemeModeFromStore();

    // Must be in portrait at init, for splash, onboarding and orientation init
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]); // Make app full screen

    return OrientationBuilder(
      builder: (context, orientation) {
        cMain.setOrientation(orientation == Orientation.portrait);
        return GetBuilder<LanguageController>(
          builder: (c) => Loading(
            child: GetMaterialApp(
              translations: Localization(),
              locale: c.getLocale, // <- Current locale
              // navigatorObservers: [
              //   // FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
              // ],
              debugShowCheckedModeBanner: false,
              // TODO these should be controlled in MenuController
              // defaultTransition: Transition.fade,
              // transitionDuration:
              //     const Duration(milliseconds: 1000),
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: ThemeMode.system, // TODO test this
              initialRoute: "/",
              getPages: AppRoutes.routes,
            ),
          ),
        );
      },
    );
  }
}
