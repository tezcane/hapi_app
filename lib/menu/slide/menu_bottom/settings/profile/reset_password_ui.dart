import 'package:flutter/material.dart';
import 'package:hapi/components/form_input_field_with_icon.dart';
import 'package:hapi/components/form_vertical_spacing.dart';
import 'package:hapi/components/logo_graphic_header.dart';
import 'package:hapi/components/primary_button.dart';
import 'package:hapi/helpers/validator.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';

/// Sends a password reset email to the user.
class ResetPasswordUI extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final AuthController authController = AuthController.to;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // set initial email from what user already entered on previous screen
    emailController.text = authController.emailController.text;
    return FabSubPage(
      subPage: SubPage.Reset_Password,
      child: Form(
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
                    controller: emailController,
                    iconPrefix: Icons.email,
                    trKey: 'auth.emailFormField',
                    validator: Validator().email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {},
                    onSaved: (value) => emailController.text = value as String,
                  ),
                  const FormVerticalSpace(),
                  PrimaryButton(
                    trKey: 'auth.resetPasswordButton',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await authController.sendPasswordResetEmail(
                            emailController.text.trim());
                      }
                    },
                  ),
                  const FormVerticalSpace(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
