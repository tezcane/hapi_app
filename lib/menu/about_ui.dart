import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/settings/language/language_list_ui.dart';
import 'package:hapi/settings/theme/app_themes.dart';
import 'package:hapi/settings/theme/theme_list_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// This widget is visible when opening the about page from the [MainMenuWidget].
///
/// It displays all the information about the development of the application,
/// the inspiration sources and tools and SDK used throughout the development process.
///
/// This page uses the package `url_launcher` available at https://pub.dartlang.org/packages/url_launcher
/// to open up urls in a WebView on both iOS & Android.
class AboutUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FabSubPage(
      subPage: SubPage.About,
      child: Scaffold(
        // Note: Can't use Get.theme here, doesn't switch background color
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
          padding:
              const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  // TODO cool animations here
                  child: Hero(
                    tag: 'hapiLogo',
                    child: Image.asset(
                      'assets/images/logo/logo.png',
                      width: 175,
                      height: 175,
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: context.textTheme.headline6,
                    children: [
                      TextSpan(
                        text: 'hapi',
                        style: const TextStyle(
                            fontFamily: 'Lobster',
                            fontSize: 25.0,
                            color: AppThemes.hyperlink,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl('https://www.hapi.net'),
                      ),
                      TextSpan(
                        text:
                            ' is built by volunteers for the sake of Allah SWT.'
                            '\n\n'
                            'We hope it helps improve your hapi-ness, in this life '
                            'and the next.'
                            '\n\n'
                            'hapi will never track or sell personal information.'
                            '\n\n'
                            'Support us with dua, telling others and donating '
                            'towards maintenence, further development and social '
                            'outreach programs: ',
                      ),
                      TextSpan(
                        text: 'paypal',
                        style: const TextStyle(
                            color: AppThemes.hyperlink,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              () => _launchUrl('https://www.paypal.net/hapi'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                LanguageListUI(),
                ThemeListUI(),
                const SizedBox(height: 24.0),
                Center(
                  child: Hero(
                    tag: 'UPDATE PROFILE',
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          MenuController.to.pushSubPage(SubPage.Update_Profile),
                      icon: const Icon(Icons.perm_identity_outlined),
                      label: Text('settings.updateProfile'.tr),
                    ),
                  ),
                ),
                const SizedBox(height: 400.0),
                const Text(
                  'hapi app v0.0.0', // TODO tie to build release version
                  style: TextStyle(fontSize: 17.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sanity check before opening up the url.
  _launchUrl(String url) {
    canLaunch(url).then((bool success) {
      if (success) {
        launch(url);
      }
    });
  }
}
