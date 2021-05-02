import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:url_launcher/url_launcher.dart';

/// This widget is visible when opening the about page from the [MainMenuWidget].
///
/// It displays all the information about the development of the application,
/// the inspiration sources and tools and SDK used throughout the development process.
///
/// This page uses the package `url_launcher` available at https://pub.dartlang.org/packages/url_launcher
/// to open up urls in a WebView on both iOS & Android.
class AboutUI extends StatelessWidget {
  /// Sanity check before opening up the url.
  _launchUrl(String url) {
    canLaunch(url).then((bool success) {
      if (success) {
        launch(url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.logoBackground,
      body: Padding(
        padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                // TODO cool animations here
                child: Image.asset(
                  'assets/images/logo/logo.png',
                  width: 250,
                  height: 250,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                      //color: darkText.withOpacity(darkText.opacity * 0.75),
                      fontFamily: 'Roboto',
                      fontSize: 17.0,
                      height: 1.5),
                  children: [
                    TextSpan(
                        text: 'hapi',
                        style: TextStyle(
                            fontFamily: 'Lobster',
                            fontSize: 25.0,
                            color: AppThemes.logoText,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl('https://www.hapi.net')),
                    TextSpan(
                      text: ' is built by volunteer Muslim engineers, '
                          'scholars and historians.'
                          '\n\n'
                          'We hope it helps improve your hapi-ness, in this world '
                          'and the next. May Allah SWT give us Firdaus. Ameen! '
                          '\n\n'
                          'hapi will never track or sell your personal information. '
                          'Please support us by telling others and donating.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50.0),
              Text(
                'hapi app version 0.0.0', // TODO tie to build release version
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 17.0,
                  height: 1.5,
                  //color: Color.white; //darkText.withOpacity(darkText.opacity * 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
