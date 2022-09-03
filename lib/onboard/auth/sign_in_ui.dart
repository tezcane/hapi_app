import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/form_input_field_with_icon.dart';
import 'package:hapi/components/form_vertical_spacing.dart';
import 'package:hapi/components/label_button.dart';
import 'package:hapi/components/logo_graphic_header.dart';
import 'package:hapi/components/primary_button.dart';
import 'package:hapi/helpers/validator.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/profile/reset_password_ui.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/onboard/auth/sign_up_ui.dart';

/// allows user to login with email and password.
class SignInUI extends StatelessWidget {
  final AuthController authController = AuthController.to;
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
                    controller: authController.emailController,
                    iconPrefix: Icons.email,
                    trKey: 'auth.emailFormField',
                    validator: Validator().email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {},
                    onSaved: (value) =>
                        authController.emailController.text = value!,
                  ),
                  const FormVerticalSpace(),
                  FormInputFieldWithIcon(
                    controller: authController.passwordController,
                    iconPrefix: Icons.lock,
                    trKey: 'auth.passwordFormField',
                    validator: Validator().password,
                    obscureText: true,
                    onChanged: (value) {},
                    onSaved: (value) =>
                        authController.passwordController.text = value!,
                    maxLines: 1,
                  ),
                  const FormVerticalSpace(),
                  PrimaryButton(
                      trKey: 'auth.signInButton',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          authController.signInWithEmailAndPassword(context);
                        }
                      }),
                  const FormVerticalSpace(),
                  LabelButton(
                    trKey: 'auth.resetPasswordLabelButton',
                    onPressed: () => Get.to(() => ResetPasswordUI()),
                  ),
                  LabelButton(
                    trKey: 'auth.signUpLabelButton',
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
