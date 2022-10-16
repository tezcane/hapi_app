import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapi/component/form_input_field_with_icon.dart';
import 'package:hapi/component/form_vertical_spacing.dart';
import 'package:hapi/component/label_button.dart';
import 'package:hapi/component/logo_graphic_header.dart';
import 'package:hapi/component/primary_button.dart';
import 'package:hapi/controller/text_update_c.dart';
import 'package:hapi/helper/validator.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/onboard/user_model.dart';

/// contains the settings screen for setting the theme and language and some user settings.
class UpdateProfileUI extends StatelessWidget {
  static final _formKey1 = GlobalKey<FormState>();
  static final _formKey2 = GlobalKey<FormState>();
  final AuthC c = AuthC.to;

  @override
  Widget build(BuildContext context) {
    return FabSubPage(
      subPage: SubPage.Update_Profile,
      child: Form(
        key: _formKey1,
        child: GetBuilder<TextUpdateC>(
          init: TextUpdateC(), // init fresh every time
          builder: (tuc) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 48),
                      LogoGraphicHeader(),
                      const SizedBox(height: 48),
                      FormInputFieldWithIcon(
                        controller: c.nameController,
                        prefixIcon: Icons.person,
                        tk: 'Name',
                        validator: Validator().name,
//                      keyboardType: TextInputType.text,
                        onChanged: (value) => tuc.handleTextUpdate(
                          [c.nameController.text, c.emailController.text],
                          [c.fsUser.value!.name, c.fsUser.value!.email],
                        ),
                        onSaved: (value) => c.nameController.text = value!,
                      ),
                      const FormVerticalSpace(),
                      FormInputFieldWithIcon(
                        controller: c.emailController,
                        prefixIcon: Icons.email,
                        tk: 'Email',
                        validator: Validator().email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => tuc.handleTextUpdate(
                          [c.nameController.text, c.emailController.text],
                          [c.fsUser.value!.name, c.fsUser.value!.email],
                        ),
                        onSaved: (value) => c.emailController.text = value!,
                      ),
                      const FormVerticalSpace(),
                      Hero(
                        tag: 'UPDATE PROFILE',
                        child: PrimaryButton(
                          tk: 'Update Profile',
                          onPressed: tuc.isTextSame
                              ? () => showSnackBar(
                                    'Update a setting first',
                                    '',
                                    isRed: true,
                                  )
                              : () async {
                                  if (_formKey1.currentState!.validate()) {
                                    SystemChannels.textInput
                                        .invokeMethod('TextInput.hide');
                                    UserModel _updatedUser = UserModel(
                                      uid: c.fsUser.value!.uid,
                                      name: c.nameController.text.trim(),
                                      email: c.emailController.text.trim(),
                                      photoUrl: c.fsUser.value!.photoUrl,
                                    );
                                    _updateUserConfirm(
                                      context,
                                      _updatedUser,
                                      c.fsUser.value!.email,
                                      tuc,
                                    );
                                  }
                                },
                          buttonStyle: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                              // ignore: body_might_complete_normally_nullable
                              (_) {
                                if (tuc.isTextSame) return Colors.grey;
                              },
                            ),
                          ),
                        ),
                      ),
                      const FormVerticalSpace(),
                      LabelButton(
                        tk: 'Send a password reset email',
                        onPressed: () =>
                            MenuC.to.pushSubPage(SubPage.Reset_Password),
                      ),
                      const SizedBox(height: 400), //hide sign out down page
                      Center(
                        child: ElevatedButton(
                          onPressed: () => MainC.to.signOut(),
                          child: T('Sign Out', null, w: wm(context)),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateUserConfirm(
    BuildContext context,
    UserModel updatedUser,
    String oldEmail,
    TextUpdateC tuc,
  ) {
    final TextEditingController _password = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          title: T('Enter Your Password', null, w: wm(context)),
          content: Form(
            key: _formKey2,
            child: FormInputFieldWithIcon(
              controller: _password,
              prefixIcon: Icons.lock,
              tk: 'Password',
              validator: Validator().password,
              obscureText: true,
              onChanged: (value) {},
              onSaved: (value) => _password.text = value!,
              maxLines: 1,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: T('Cancel', null, w: wm(context)),
              onPressed: () {
                // revert text back
                c.nameController.text = c.fsUser.value!.name;
                c.emailController.text = c.fsUser.value!.email;
                tuc.setTextSame(true); // disable update profile button
                Navigator.of(context).pop(); // Get.back() doesn't work!
              },
            ),
            TextButton(
              child: T('Submit', null, w: wm(context)),
              onPressed: () async {
                if (_formKey2.currentState!.validate()) {
                  bool failed = await c.updateUser(
                      context, updatedUser, oldEmail, _password.text);
                  if (!failed) tuc.setTextSame(true); // new val in profile now
                  Navigator.of(context).pop(); // Get.back() doesn't work!
                }
              },
            )
          ],
        );
      },
    );
  }
}
