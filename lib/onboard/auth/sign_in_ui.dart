import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/form_input_field_with_icon.dart';
import 'package:hapi/component/form_vertical_spacing.dart';
import 'package:hapi/component/label_button.dart';
import 'package:hapi/component/logo_graphic_header.dart';
import 'package:hapi/component/primary_button.dart';
import 'package:hapi/helper/validator.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/profile/reset_password_ui.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/onboard/auth/sign_up_ui.dart';

/// allows user to login with email and password.
class SignInUI extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  LogoGraphicHeader(),
                  const SizedBox(height: 48.0),
                  FormInputFieldWithIcon(
                    controller: AuthC.to.emailController,
                    iconPrefix: Icons.email,
                    tk: 'Email',
                    validator: Validator().email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {},
                    onSaved: (value) => AuthC.to.emailController.text = value!,
                  ),
                  const FormVerticalSpace(),
                  FormInputFieldWithIcon(
                    controller: AuthC.to.passwordController,
                    iconPrefix: Icons.lock,
                    tk: 'Password',
                    validator: Validator().password,
                    obscureText: true,
                    onChanged: (value) {},
                    onSaved: (value) =>
                        AuthC.to.passwordController.text = value!,
                    maxLines: 1,
                  ),
                  const FormVerticalSpace(),
                  PrimaryButton(
                      tk: 'Sign In',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          AuthC.to.signInWithEmailAndPassword(context);
                        }
                      }),
                  const FormVerticalSpace(),
                  LabelButton(
                    tk: 'Forgot password?',
                    onPressed: () => Get.to(() => ResetPasswordUI()),
                  ),
                  LabelButton(
                    tk: 'Create an account',
                    onPressed: () => Get.to(() => SignUpUI()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
