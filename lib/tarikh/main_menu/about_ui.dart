import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/tarikh/colors.dart';
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
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: lightGrey,
        iconTheme: IconThemeData(color: Colors.black.withOpacity(0.54)),
        elevation: 0.0,
        leading: IconButton(
          alignment: Alignment.centerLeft,
          icon: Icon(Icons.arrow_back),
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          color: Colors.black.withOpacity(0.5),
          onPressed: () {
            Get.back(); // had Navigator.pop(context, true);
          },
        ),
        titleSpacing:
            9.0, // Note that the icon has 20 on the right due to its padding, so we add 10 to get our desired 29
        title: Text("About",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: "RobotoMedium",
                fontSize: 20.0,
                color: darkText.withOpacity(darkText.opacity * 0.75))),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // TODO put logo here
              "hapi",
              style: TextStyle(
                  fontFamily: "RobotoMedium",
                  fontSize: 34.0,
                  color: darkText.withOpacity(darkText.opacity * 0.75)),
            ),
            Expanded(
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: darkText.withOpacity(darkText.opacity * 0.75),
                          fontFamily: "Roboto",
                          fontSize: 17.0,
                          height: 1.5),
                      children: [
                        TextSpan(
                            text: "hapi",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap =
                                  () => _launchUrl("https://www.hapi.net")),
                        TextSpan(
                          text: " is built by volunteer Muslim engineers, "
                              "scholars and historians."
                              "\n\n"
                              "We hope it helps improve your life, in this world "
                              "and the next. May Allah SWT give us Firdaus. Ameen! "
                              "This is true hapiness[sic]."
                              "\n\n"
                              "Please help us grow this project by telling "
                              "others and donating.", // TODO link here
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 17.0, bottom: 14.0),
              child: Text(
                "hapi app version 0.0.0", // TODO tie to build release version
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 17.0,
                    height: 1.5,
                    color: darkText.withOpacity(darkText.opacity * 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
