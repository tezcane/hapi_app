import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapi/components/form_input_field_with_icon.dart';
import 'package:hapi/components/form_vertical_spacing.dart';
import 'package:hapi/components/label_button.dart';
import 'package:hapi/components/logo_graphic_header.dart';
import 'package:hapi/components/primary_button.dart';
import 'package:hapi/controllers/text_update_controller.dart';
import 'package:hapi/helpers/validator.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/onboard/user_model.dart';

/// contains the settings screen for setting the theme and language and some user settings.
class UpdateProfileUI extends StatelessWidget {
  static final _formKey1 = GlobalKey<FormState>();
  static final _formKey2 = GlobalKey<FormState>();
  final AuthController c = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return FabSubPage(
      subPage: SubPage.Update_Profile,
      child: Form(
        key: _formKey1,
        child: GetBuilder<TextUpdateController>(
          init: TextUpdateController(), // init fresh every time
          builder: (tu) {
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
                        iconPrefix: Icons.person,
                        trKey: 'auth.nameFormField',
                        validator: Validator().name,
                        onChanged: (value) => tu.handleTextUpdate(
                          [
                            c.nameController.text,
                            c.emailController.text,
                          ],
                          [
                            c.firestoreUser.value!.name,
                            c.firestoreUser.value!.email,
                          ],
                        ),
                        onSaved: (value) => c.nameController.text = value!,
                      ),
                      const FormVerticalSpace(),
                      FormInputFieldWithIcon(
                        controller: c.emailController,
                        iconPrefix: Icons.email,
                        trKey: 'auth.emailFormField',
                        validator: Validator().email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => tu.handleTextUpdate(
                          [
                            c.nameController.text,
                            c.emailController.text,
                          ],
                          [
                            c.firestoreUser.value!.name,
                            c.firestoreUser.value!.email,
                          ],
                        ),
                        onSaved: (value) => c.emailController.text = value!,
                      ),
                      const FormVerticalSpace(),
                      Hero(
                        tag: 'UPDATE PROFILE',
                        child: PrimaryButton(
                          trKey: 'i.Update Profile',
                          onPressed: tu.isTextSame
                              ? () {} // disable button
                              : () async {
                                  if (_formKey1.currentState!.validate()) {
                                    SystemChannels.textInput
                                        .invokeMethod('TextInput.hide');
                                    UserModel _updatedUser = UserModel(
                                      uid: c.firestoreUser.value!.uid,
                                      name: c.nameController.text.trim(),
                                      email: c.emailController.text.trim(),
                                      photoUrl:
                                          c.firestoreUser.value!.photoUrl,
                                    );
                                    _updateUserConfirm(
                                      context,
                                      _updatedUser,
                                      c.firestoreUser.value!.email,
                                      tu,
                                    );
                                  }
                                },
                          buttonStyle: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith(
                              // ignore: body_might_complete_normally_nullable
                              (_) {
                                if (tu.isTextSame) {
                                  return Colors.grey; // disabled color
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const FormVerticalSpace(),
                      LabelButton(
                          trKey: 'auth.resetPasswordLabelButton',
                          onPressed: () => MenuController.to
                              .pushSubPage(SubPage.Reset_Password)),
                      const SizedBox(height: 400), //hide sign out down page
                      Center(
                        child: ElevatedButton(
                          onPressed: () => MainController.to.signOut(),
                          child:
                              T('settings.signOut', null, w: wm(context)),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Future<void> _updateUserConfirm(
    BuildContext context,
    UserModel updatedUser,
    String oldEmail,
    TextUpdateController tu,
  ) {
    final TextEditingController _password = TextEditingController();
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              title: T('auth.enterPasswordTitle', null, w: wm(context)),
              content: Form(
                key: _formKey2,
                child: FormInputFieldWithIcon(
                  controller: _password,
                  iconPrefix: Icons.lock,
                  trKey: 'auth.passwordFormField',
                  validator: Validator().password,
                  obscureText: true,
                  onChanged: (value) {},
                  onSaved: (value) => _password.text = value!,
                  maxLines: 1,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: T('auth.cancel', null, w: wm(context)),
                  onPressed: () {
                    // revert text back
                    c.nameController.text = c.firestoreUser.value!.name;
                    c.emailController.text = c.firestoreUser.value!.email;
                    tu.setTextSame(true); // disable update profile button
                    Navigator.of(context).pop(); // Get.back() doesn't work!
                  },
                ),
                TextButton(
                  child: T('auth.submit', null),
                  onPressed: () async {
                    if (_formKey2.currentState!.validate()) {
                      bool failed = await c.updateUser(
                          context, updatedUser, oldEmail, _password.text);
                      if (!failed) {
                        tu.setTextSame(true); // new values in profile now
                      }
                      Navigator.of(context).pop();  // Get.back() doesn't work!
                    }
                  },
                )
              ],
            );
        }
    );
  }
}
