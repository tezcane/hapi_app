import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hapi/component/form_input_field_with_icon.dart';
import 'package:hapi/component/form_vertical_spacing.dart';
import 'package:hapi/component/logo_graphic_header.dart';
import 'package:hapi/component/primary_button.dart';
import 'package:hapi/helper/validator.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/onboard/auth/auth_c.dart';

/// allows user to create a new account.
class SignUpUI extends StatelessWidget {
  const SignUpUI();

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return FabSubPage(
      subPage: SubPage.Sign_Up,
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
                    controller: AuthC.to.nameController,
                    prefixIcon: Icons.person,
                    tk: 'Name',
                    validator: Validator().name,
                    onChanged: (value) {},
                    onSaved: (value) => AuthC.to.nameController.text = value!,
                  ),
                  const FormVerticalSpace(),
                  FormInputFieldWithIcon(
                    controller: AuthC.to.emailController,
                    prefixIcon: Icons.email,
                    tk: 'Email',
                    validator: Validator().email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {},
                    onSaved: (value) => AuthC.to.emailController.text = value!,
                  ),
                  const FormVerticalSpace(),
                  FormInputFieldWithIcon(
                    controller: AuthC.to.passwordController,
                    prefixIcon: Icons.lock,
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
                      tk: 'Sign Up',
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          SystemChannels.textInput.invokeMethod(
                              'TextInput.hide'); //to hide the keyboard - if any
                          AuthC.to.registerWithEmailAndPassword(context);
                        }
                      }),
                  // const FormVerticalSpace(),
                  // LabelButton(
                  //   tk: 'Have an account? Sign in to your account.',
                  //   onPressed: () => Get.to(() => SignInUI()),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
