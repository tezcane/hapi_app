import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hapi/components/form_input_field_with_icon.dart';
import 'package:hapi/components/form_vertical_spacing.dart';
import 'package:hapi/components/label_button.dart';
import 'package:hapi/components/logo_graphic_header.dart';
import 'package:hapi/components/primary_button.dart';
import 'package:hapi/helpers/validator.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/onboard/user_model.dart';
import 'package:hapi/settings/text_update_controller.dart';

/// contains the settings screen for setting the theme and language and some user settings.
class UpdateProfileUI extends StatelessWidget {
  static final _formKey1 = GlobalKey<FormState>();
  static final _formKey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return FabSubPage(
      subPage: SubPage.Update_Profile,
      child: Form(
        key: _formKey1,
        child: GetBuilder<AuthController>(
          builder: (c) {
            // on init, set names to what is stored in db
            c.nameController.text = c.firestoreUser.value!.name;
            c.emailController.text = c.firestoreUser.value!.email;
            return GetBuilder<TextUpdateController>(
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
                            labelText: 'auth.nameFormField'.tr,
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
                            labelText: 'auth.emailFormField'.tr,
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
                              labelText: 'auth.updateUser',
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
                              labelText: 'auth.resetPasswordLabelButton'.tr,
                              onPressed: () => MenuController.to
                                  .pushSubPage(SubPage.Reset_Password)),
                          const SizedBox(height: 400), // hide signout down page
                          Center(
                            child: ElevatedButton(
                              onPressed: () => AuthController.to.signOut(),
                              child: Text('settings.signOut'.tr),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
    TextUpdateController tu,
  ) async {
    final AuthController authController = AuthController.to;
    final TextEditingController _password = TextEditingController();
    return Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        title: Text(
          'auth.enterPassword'.tr,
        ),
        content: Form(
          key: _formKey2,
          child: FormInputFieldWithIcon(
            controller: _password,
            iconPrefix: Icons.lock,
            labelText: 'auth.passwordFormField'.tr,
            validator: Validator().password,
            obscureText: true,
            onChanged: (value) {},
            onSaved: (value) => _password.text = value!,
            maxLines: 1,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('auth.cancel'.tr.toUpperCase()),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('auth.submit'.tr.toUpperCase()),
            onPressed: () async {
              if (_formKey2.currentState!.validate()) {
                Get.back();
                bool failed = await authController.updateUser(
                    context, updatedUser, oldEmail, _password.text);
                if (!failed) {
                  tu.setTextSame(true); // new values in profile now
                }
              }
            },
          )
        ],
      ),
    );
  }
}
