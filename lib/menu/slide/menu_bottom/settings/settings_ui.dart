import 'package:flutter/material.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_list_ui.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/theme_list_ui.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/onboard/onboard_ui.dart';

class SettingsUI extends StatelessWidget {
  const SettingsUI();

  @override
  Widget build(BuildContext context) {
    OnboardUI.menuViewedSettingsGlobal = true;
    NavPageC.to.updateOnThread1Ms();

    double padding = 20; // p for padding
    double width = w(context) - padding * 2;
    return FabSubPage(
      subPage: SubPage.Settings,
      child: Scaffold(
        // Note: Can't use Get.theme here, doesn't switch background color
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  const SizedBox(height: 20.0),
                  SizedBox(height: 55, child: LangListUI(width, true)),
                  const SizedBox(height: 20.0),
                  SizedBox(height: 55, child: ThemeListUI(width)),
                  if (MainC.to.isSignedIn) const SizedBox(height: 20.0),
                  if (MainC.to.isSignedIn) // hide in onboard tutorial
                    Center(
                      child: Hero(
                        tag: 'UPDATE PROFILE',
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              MenuC.to.pushSubPage(SubPage.Update_Profile),
                          icon: const Icon(Icons.perm_identity_outlined),
                          label: T('Update Profile', null, w: wm(context)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20.0),
                  T('hapi app v0.0.0', tsN, w: width / 2), // TODO automate v#
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
