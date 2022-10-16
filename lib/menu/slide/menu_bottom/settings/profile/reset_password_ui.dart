import 'package:flutter/material.dart';
import 'package:hapi/component/form_input_field_with_icon.dart';
import 'package:hapi/component/form_vertical_spacing.dart';
import 'package:hapi/component/logo_graphic_header.dart';
import 'package:hapi/component/primary_button.dart';
import 'package:hapi/helper/validator.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/onboard/auth/auth_c.dart';

/// Sends a password reset email to the user.
class ResetPasswordUI extends StatelessWidget {
  const ResetPasswordUI();

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // set initial email from what user already entered on previous screen
    emailController.text = AuthC.to.emailController.text;
    return FabSubPage(
      subPage: SubPage.Reset_Password,
      child: Form(
        key: formKey,
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
                    prefixIcon: Icons.email,
                    tk: 'Email',
                    validator: Validator().email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {},
                    onSaved: (value) => emailController.text = value as String,
                  ),
                  const FormVerticalSpace(),
                  PrimaryButton(
                    tk: 'Send a password reset email',
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await AuthC.to.sendPasswordResetEmail(
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
