import 'dart:core';

import 'package:flutter/material.dart';
import 'package:hapi/component/form_vertical_spacing.dart';
import 'package:hapi/component/primary_button.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/sub_page.dart';

/// If user is signed in, just show exit tutorial button.  If not signed in
/// give them two options: Sign In or Sign Up buttons.
class SignInUpUI extends StatelessWidget {
  const SignInUpUI();

  @override
  Widget build(BuildContext context) {
    final double logoWidthAndHeight =
        (MainC.to.isPortrait ? w(context) : h(context)) / GR;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              const SizedBox(height: 48.0),
              MainC.to.isSignedIn
                  ? Column(children: <Widget>[
                      T('You are already signed in.', ts),
                      const FormVerticalSpace(),
                      PrimaryButton(
                        tk: 'Exit Tutorial',
                        onPressed: () =>
                            MenuC.to.navigateToNavPageAndResetFAB(),
                      ),
                    ])
                  : Column(children: <Widget>[
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
