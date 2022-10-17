import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/form_vertical_spacing.dart';
import 'package:hapi/component/primary_button.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/bottom_bar_menu.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_list_ui.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/menu/sub_page.dart';

/// If user is signed in, just show exit tutorial button.  If not signed in
/// give them two options: Sign In or Sign Up buttons.
class TutorialAndSignInUpUI extends StatelessWidget {
  const TutorialAndSignInUpUI();

  @override
  Widget build(BuildContext context) {
    final double width = w(context);
    final double logoWidthAndHeight =
        (MainC.to.isPortrait ? width : h(context)) / GR;

    const double topLeftRightPad = 12;
//  const double bottomPad = 72; // height of bottom bar buttons

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(
          // top: topLeftRightPad,
          left: topLeftRightPad,
          right: topLeftRightPad,
          //bottom: bottomPad, // needed on landscape or will look funny
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Center(
                child: Image.asset(
                  'assets/images/logo/logo.png',
                  width: logoWidthAndHeight,
                  height: logoWidthAndHeight,
                ),
              ),
              if (!MainC.to.isSignedIn)
                Column(children: <Widget>[
                  // const FormVerticalSpace(),
                  SizedBox(
                    height: 55,
                    child: LangListUI(width - topLeftRightPad * 2, false),
                  ),
                  // const FormVerticalSpace(),
                  // RichText(
                  //   text: TextSpan(
                  //     style: context.textTheme.headline5,
                  //     children: [TextSpan(text: 'Welcome to hapi!'.tr)],
                  //   ),
                  // ),
                ]),
              const FormVerticalSpace(),
              RichText(
                text: TextSpan(
                  style: context.textTheme.headline6,
                  children: [
                    TextSpan(
                      text: 'hapi is a useful and fun Islamic lifestyle app.'
                              .tr +
                          ' ' +
                          "It's meant to elevate Muslims, in this life and the next."
                              .tr +
                          ' ' +
                          'Earn rewards, increase knowledge and develop good habits with hapi.'
                              .tr,
                    ),
                  ],
                ),
              ),
              const FormVerticalSpace(),
              PrimaryButton(
                tk: 'Start Tutorial',
                onPressed: () => BottomBarMenu.animateToPage(NavPage.Mithal, 1),
              ),
              MainC.to.isSignedIn
                  ? Column(children: <Widget>[
                      const FormVerticalSpace(),
                      PrimaryButton(
                        tk: 'Exit Tutorial',
                        onPressed: () =>
                            MenuC.to.navigateToNavPageAndResetFAB(),
                      ),
                    ])
                  : Column(children: <Widget>[
                      const FormVerticalSpace(),
                      PrimaryButton(
                        tk: 'Sign Up',
                        onPressed: () => MenuC.to.pushSubPage(SubPage.Sign_Up),
                      ),
                      const FormVerticalSpace(),
                      PrimaryButton(
                        tk: 'Sign In',
                        onPressed: () => MenuC.to.pushSubPage(SubPage.Sign_In),
                      ),
                    ]),
            ]),
          ),
        ),
      ),
    );
  }
}
