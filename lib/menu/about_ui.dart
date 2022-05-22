import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';
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
    double padding = 20; // p for padding
    double width = w(context) - padding * 2;
    return FabSubPage(
      subPage: SubPage.About,
      child: Scaffold(
        // Note: Can't use Get.theme here, doesn't switch background color
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 50,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: 'hapiLogo',
                    child: Image.asset(
                      'assets/images/logo/logo.png',
                      width: 175,
                      height: 175,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                RichText(
                  text: TextSpan(
                    style: context.textTheme.headline6,
                    children: [
                      // TextSpan(
                      //   text: 'hapi',
                      //   style: const TextStyle(
                      //       fontFamily: 'Lobster',
                      //       fontSize: 25.0,
                      //       color: AppThemes.hyperlink,
                      //       decoration: TextDecoration.underline),
                      //   recognizer: TapGestureRecognizer()
                      //     ..onTap = () => _launchUrl('https://hapi.net'),
                      // ),
                      TextSpan(
                        text: at(
                                'at.{0} is made by volunteers for the sake of {1} {2}.',
                                [
                                  'a.hapi',
                                  'a.Allah',
                                  'a.SWT'
                                ]) +
                            '\n\n' +
                            'i.We hope it greatly improves your happiness in this life and the next.'
                                .tr +
                            '\n\n' +
                            at('at.{0} will never track or sell your data and will remain free.',
                                ['a.hapi']) +
                            '\n\n' +
                            at('at.You can support {0} with your {1}, sharing {2} and donating towards server costs, further developments and social outreach programs.',
                                ['a.hapi', 'a.dua', 'a.hapi']) +
                            '\n\n' +
                            'i.Learn more at'.tr +
                            ' ',
                      ),
                      TextSpan(
                        text: 'hapi.net',
                        style: const TextStyle(
                            color: AppThemes.hyperlink,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl('https://hapi.net'),
                      ),
                    ],
                  ),
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
