import 'package:flutter/material.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/settings/language/language_list_ui.dart';
import 'package:hapi/settings/theme/theme_list_ui.dart';

class SettingsUI extends StatelessWidget {
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
                const SizedBox(height: 30.0),
                SizedBox(height: 55, child: LanguageListUI(width)),
                const SizedBox(height: 20.0),
                SizedBox(height: 55, child: ThemeListUI(width)),
                const SizedBox(height: 20.0),
                Center(
                  child: Hero(
                    tag: 'UPDATE PROFILE',
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          MenuController.to.pushSubPage(SubPage.Update_Profile),
                      icon: const Icon(Icons.perm_identity_outlined),
                      label: T('i.Update Profile', null, w: wm(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 400.0),
                T('hapi app v0.0.0', tsN, w: width / 2), // TODO automate v#
              ],
            ),
          ),
        ),
      ),
    );
  }
}
